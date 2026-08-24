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

use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;
use App\Entity\Atendimento;
use Novosga\Entity\AtendimentoInterface;
use Novosga\Entity\ServicoInterface;
use Novosga\Entity\UnidadeInterface;
use Novosga\Repository\AtendimentoRepositoryInterface;
use Novosga\Service\AtendimentoServiceInterface;

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
    public function findIssuedByCustomer(UnidadeInterface $unidade, ?string $nome, ?string $cpf): array
    {
        $qb = $this->createQueryBuilder('a')
            ->innerJoin('a.cliente', 'c')
            ->andWhere('a.unidade = :unidade')
            ->andWhere('a.status = :status')
            ->setParameter('unidade', $unidade)
            ->setParameter('status', AtendimentoServiceInterface::SENHA_EMITIDA)
            ->orderBy('a.dataChegada', 'DESC')
            ->setMaxResults(50);

        if ($nome !== null && $nome !== '') {
            $qb
                ->andWhere('LOWER(c.nome) LIKE LOWER(:nome)')
                ->setParameter('nome', '%' . $nome . '%');
        }

        if ($cpf !== null && $cpf !== '') {
            $digits = preg_replace('/\D+/', '', $cpf);
            $formatted = strlen($digits) === 11
                ? preg_replace('/(\d{3})(\d{3})(\d{3})(\d{2})/', '$1.$2.$3-$4', $digits)
                : $digits;
            $qb
                ->andWhere('c.documento LIKE :cpf OR c.documento LIKE :cpfFormatted')
                ->setParameter('cpf', '%' . $digits . '%')
                ->setParameter('cpfFormatted', '%' . $formatted . '%');
        }

        return $qb->getQuery()->getResult();
    }
}
