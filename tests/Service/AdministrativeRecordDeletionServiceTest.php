<?php

declare(strict_types=1);

namespace App\Tests\Service;

use App\Service\AdministrativeRecordDeletionService;
use Doctrine\DBAL\Connection;
use PHPUnit\Framework\TestCase;

final class AdministrativeRecordDeletionServiceTest extends TestCase
{
    public function testDeletesUserInsideTransactionAndIncludesEveryLinkedTable(): void
    {
        $connection = $this->createMock(Connection::class);
        $connection->expects($this->once())
            ->method('transactional')
            ->willReturnCallback(static function (callable $callback) use ($connection): void {
                $callback($connection);
            });

        $sql = [];
        $connection->expects($this->exactly(16))
            ->method('executeStatement')
            ->willReturnCallback(static function (string $statement) use (&$sql): int {
                $sql[] = $statement;
                return 1;
            });

        (new AdministrativeRecordDeletionService($connection))->deleteUser(7, 'operador');

        $joined = implode("\n", $sql);
        foreach ([
            'atendimentos_codificados',
            'atendimentos_metadata',
            'historico_atendimentos_codificados',
            'historico_atendimentos_metadata',
            'servicos_usuarios',
            'lotacoes',
            'usuarios_metadata',
            'oauth2_refresh_token',
            'oauth2_authorization_code',
            'oauth2_access_token',
            'DELETE FROM usuarios',
        ] as $table) {
            self::assertStringContainsString($table, $joined);
        }
    }

    public function testDeletesCustomerInsideTransactionAndIncludesEveryLinkedTable(): void
    {
        $connection = $this->createMock(Connection::class);
        $connection->expects($this->once())
            ->method('transactional')
            ->willReturnCallback(static function (callable $callback) use ($connection): void {
                $callback($connection);
            });

        $sql = [];
        $connection->expects($this->exactly(12))
            ->method('executeStatement')
            ->willReturnCallback(static function (string $statement) use (&$sql): int {
                $sql[] = $statement;
                return 1;
            });

        (new AdministrativeRecordDeletionService($connection))->deleteCustomer(9);

        $joined = implode("\n", $sql);
        foreach ([
            'atendimentos_codificados',
            'atendimentos_metadata',
            'historico_atendimentos_codificados',
            'historico_atendimentos_metadata',
            'agendamentos',
            'clientes_metadata',
            'DELETE FROM clientes',
        ] as $table) {
            self::assertStringContainsString($table, $joined);
        }
    }
}
