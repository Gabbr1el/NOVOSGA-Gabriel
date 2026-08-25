<?php

declare(strict_types=1);

namespace App\Tests\Service;

use App\Service\AdministrativeRecordDeletionService;
use Doctrine\DBAL\Connection;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

final class AdministrativeRecordDeletionServiceIntegrationTest extends KernelTestCase
{
    private Connection $connection;

    protected function setUp(): void
    {
        self::bootKernel();
        $this->connection = static::getContainer()->get(Connection::class);
        $this->connection->beginTransaction();
    }

    protected function tearDown(): void
    {
        $this->connection->rollBack();
        parent::tearDown();
    }

    public function testDeletesCustomerAndEveryDirectDatabaseRecord(): void
    {
        $document = 'purge-test-123';
        $this->connection->insert('clientes', [
            'nome' => 'Paciente para exclusão',
            'documento' => $document,
        ]);
        $customerId = (int) $this->connection->lastInsertId();

        $this->connection->insert('clientes_metadata', [
            'namespace' => 'test',
            'name' => 'purge',
            'cliente_id' => $customerId,
            'value' => '{}',
        ]);
        $this->connection->insert('agendamentos', [
            'cliente_id' => $customerId,
            'data' => '2026-08-25',
            'hora' => '08:00:00',
            'situacao' => 'agendado',
        ]);
        $this->connection->insert('painel_senha', [
            'num_senha' => 1,
            'sig_senha' => 'T',
            'msg_senha' => 'Teste',
            'local' => 'Sala',
            'num_local' => 1,
            'peso' => 1,
            'documento_cliente' => $document,
        ]);

        static::getContainer()->get(AdministrativeRecordDeletionService::class)->deleteCustomer($customerId);

        foreach (['clientes', 'clientes_metadata', 'agendamentos'] as $table) {
            $count = $this->connection->fetchOne(
                "SELECT COUNT(*) FROM {$table} WHERE " . ('clientes' === $table ? 'id' : 'cliente_id') . ' = ?',
                [$customerId],
            );
            self::assertSame(0, (int) $count, $table);
        }
        self::assertSame(
            0,
            (int) $this->connection->fetchOne(
                'SELECT COUNT(*) FROM painel_senha WHERE documento_cliente = ?',
                [$document],
            ),
        );
    }
}
