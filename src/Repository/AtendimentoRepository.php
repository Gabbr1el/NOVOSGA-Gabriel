<?php

declare(strict_types=1);

/*
 * This file is part of the NovoSGA project.
 *
 * (c) Rogerio Lino <rogeriolino@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace App\Repository;

use DateTimeImmutable;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;
use App\Entity\Atendimento;
use Novosga\Entity\AtendimentoInterface;
use Novosga\Entity\ServicoInterface;
use Novosga\Entity\UnidadeInterface;
use Novosga\Repository\AtendimentoRepositoryInterface;

/**
 * @extends ServiceEntityRepository<AtendimentoInterface>
 *
 * @method Atendimento|null find($id, $lockMode = null, $lockVersion = null)
 * @method Atendimento|null findOneBy(array $criteria, array $orderBy = null)
 * @method Atendimento[]    findAll()
 * @method Atendimento[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 *
 * @author Rogério Lino <rogeriolino@gmail.com>
 */
class AtendimentoRepository extends ServiceEntityRepository implements AtendimentoRepositoryInterface
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Atendimento::class);
    }

    /** {@inheritdoc} */
    public function countByServicos(UnidadeInterface $unidade, array $servicos, ?string $status = null): array
    {
        $qb = $this
            ->getEntityManager()
            ->createQueryBuilder()
            ->select('s.id, COUNT(e) as total')
            ->from(Atendimento::class, 'e')
            ->join('e.servico', 's')
            ->where('e.unidade = :unidade')
            ->groupBy('s.id')
            ->setParameter('unidade', $unidade);

        if (count($servicos)) {
            $qb
                ->andWhere('e.servico IN (:servicos)')
                ->setParameter('servicos', $servicos);
        }

        if ($status) {
            $qb
                ->andWhere('e.status = :status')
                ->setParameter('status', $status);
        }

        $rs = $qb
            ->getQuery()
            ->getArrayResult();

        return $rs;
    }

    /** {@inheritdoc} */
    public function getUltimo(UnidadeInterface $unidade, ServicoInterface $servico = null): ?AtendimentoInterface
    {
        $qb = $this
            ->getEntityManager()
            ->createQueryBuilder()
            ->select('e')
            ->from(Atendimento::class, 'e')
            ->where('e.unidade = :unidade')
            ->orderBy('e.id', 'DESC')
            ->setParameter('unidade', $unidade->getId());

        if ($servico) {
            $qb
                ->andWhere('e.servico = :servico')
                ->setParameter('servico', $servico->getId());
        }

        $atendimento = $qb
            ->getQuery()
            ->setMaxResults(1)
            ->getOneOrNullResult();

        return $atendimento;
    }

    /** @return Atendimento[] */
    public function searchByTerm(UnidadeInterface $unidade, string $term): array
    {
        $term = trim(str_replace(['%', '_'], '', $term));
        if ($term === '') {
            return [];
        }

        $qb = $this->createQueryBuilder('a')
            ->addSelect('s', 'ut', 'u', 'c')
            ->join('a.servico', 's')
            ->join('a.usuarioTriagem', 'ut')
            ->leftJoin('a.usuario', 'u')
            ->leftJoin('a.cliente', 'c')
            ->andWhere('a.unidade = :unidade')
            ->setParameter('unidade', $unidade)
            ->orderBy('a.id', 'ASC')
            ->setMaxResults(100);

        $fields = [
            'c.nome',
            'c.documento',
            'c.email',
            'c.telefone',
            'c.genero',
            'c.observacao',
            'c.endereco.pais',
            'c.endereco.estado',
            'c.endereco.cidade',
            'c.endereco.cep',
            'c.endereco.logradouro',
            'c.endereco.numero',
            'c.endereco.complemento',
        ];
        $conditions = array_map(
            static fn (string $field): string => sprintf('LOWER(%s) LIKE LOWER(:term)', $field),
            $fields,
        );
        $qb->setParameter('term', '%' . $term . '%');

        $digits = preg_replace('/\D+/', '', $term);
        $formatted = match (strlen($digits)) {
            8 => substr($digits, 0, 5) . '-' . substr($digits, 5),
            10 => sprintf('(%s) %s-%s', substr($digits, 0, 2), substr($digits, 2, 4), substr($digits, 6)),
            11 => [
                sprintf(
                    '%s.%s.%s-%s',
                    substr($digits, 0, 3),
                    substr($digits, 3, 3),
                    substr($digits, 6, 3),
                    substr($digits, 9),
                ),
                sprintf('(%s) %s-%s', substr($digits, 0, 2), substr($digits, 2, 5), substr($digits, 7)),
            ],
            default => [],
        };
        foreach ((array) $formatted as $index => $value) {
            $parameter = 'formatted' . $index;
            $conditions[] = sprintf(
                '(c.documento LIKE :%1$s OR c.telefone LIKE :%1$s OR c.endereco.cep LIKE :%1$s)',
                $parameter,
            );
            $qb->setParameter($parameter, '%' . $value . '%');
        }

        if (preg_match('/^([[:alpha:]]+)\s*[- ]?\s*0*(\d+)$/u', $term, $ticket)) {
            $conditions[] = '(UPPER(a.senha.sigla) = :sigla AND a.senha.numero = :numero)';
            $qb
                ->setParameter('sigla', strtoupper($ticket[1]))
                ->setParameter('numero', (int) $ticket[2]);
        } elseif ($digits !== '' && $digits === $term) {
            $conditions[] = 'a.senha.numero = :numero';
            $qb->setParameter('numero', (int) $digits);
        }

        $date = DateTimeImmutable::createFromFormat('!d/m/Y', $term)
            ?: DateTimeImmutable::createFromFormat('!Y-m-d', $term);
        if ($date instanceof DateTimeImmutable) {
            $conditions[] = '(c.dataNascimento >= :dateStart AND c.dataNascimento < :dateEnd)';
            $qb
                ->setParameter('dateStart', $date)
                ->setParameter('dateEnd', $date->modify('+1 day'));
        }

        return $qb
            ->andWhere($qb->expr()->orX(...$conditions))
            ->getQuery()
            ->getResult();
    }
}
