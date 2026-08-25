<?php

declare(strict_types=1);

namespace App\Tests\Repository;

use App\Entity\Atendimento;
use App\Entity\Cliente;
use App\Entity\Endereco;
use App\Repository\AtendimentoRepository;
use App\Service\AtendimentoService;
use App\Tests\TestHelper;
use DateTimeImmutable;
use Doctrine\ORM\EntityManagerInterface;
use Novosga\Entity\PrioridadeInterface;
use Novosga\Entity\ServicoInterface;
use Novosga\Entity\UnidadeInterface;
use Novosga\Entity\UsuarioInterface;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

final class AtendimentoRepositoryTest extends KernelTestCase
{
    private EntityManagerInterface $em;

    protected function setUp(): void
    {
        self::bootKernel();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);
        $this->em->getConnection()->beginTransaction();
    }

    protected function tearDown(): void
    {
        $this->em->getConnection()->rollBack();
        parent::tearDown();
    }

    public function testSearchesTicketAndAllCustomerInformationWithinUnit(): void
    {
        $unit = TestHelper::createUnidade($this->em, 'Search Unit');
        $otherUnit = TestHelper::createUnidade($this->em, 'Other Search Unit');
        $service = TestHelper::createServico($this->em, 'Search Service');
        $priority = TestHelper::createPrioridade($this->em, 'Search Priority');
        $user = TestHelper::getUser($this->em);
        $customer = (new Cliente())
            ->setNome('Maria da Silva')
            ->setDocumento('123.456.789-01')
            ->setEmail('maria@example.com')
            ->setTelefone('(11) 98765-4321')
            ->setDataNascimento(new DateTimeImmutable('1990-05-21'))
            ->setGenero('F')
            ->setObservacao('Alergia a dipirona')
            ->setEndereco(
                (new Endereco())
                    ->setPais('BR')
                    ->setEstado('SP')
                    ->setCidade('Utinga')
                    ->setCep('09220-000')
                    ->setLogradouro('Rua das Flores')
                    ->setNumero('123')
                    ->setComplemento('Casa azul'),
            );
        $this->em->persist($customer);
        $attendance = $this->createAttendance($unit, $service, $priority, $user, $customer, 'ZX', 42);
        $this->createAttendance($otherUnit, $service, $priority, $user, $customer, 'ZX', 43);

        /** @var AtendimentoRepository $repository */
        $repository = $this->em->getRepository(Atendimento::class);
        $terms = [
            'ZX042',
            '42',
            'Maria',
            '12345678901',
            'maria@example.com',
            '11987654321',
            '21/05/1990',
            'Alergia',
            'Utinga',
            '09220000',
            'Flores',
            'Casa azul',
        ];

        foreach ($terms as $term) {
            $result = $repository->searchByTerm($unit, $term);
            $ids = array_map(static fn (Atendimento $item) => $item->getId(), $result);
            self::assertSame([$attendance->getId()], $ids, $term);
        }

        self::assertSame([], $repository->searchByTerm($unit, 'inexistente'));
        self::assertSame([], $repository->searchByTerm($unit, ''));
    }

    private function createAttendance(
        UnidadeInterface $unit,
        ServicoInterface $service,
        PrioridadeInterface $priority,
        UsuarioInterface $user,
        Cliente $customer,
        string $prefix,
        int $number,
    ): Atendimento {
        $attendance = (new Atendimento())
            ->setUnidade($unit)
            ->setServico($service)
            ->setPrioridade($priority)
            ->setUsuarioTriagem($user)
            ->setCliente($customer)
            ->setDataChegada(new DateTimeImmutable())
            ->setStatus(AtendimentoService::SENHA_EMITIDA);
        $attendance->getSenha()->setSigla($prefix)->setNumero($number);
        $this->em->persist($attendance);
        $this->em->flush();

        return $attendance;
    }
}
