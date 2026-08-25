<?php

declare(strict_types=1);

namespace App\Service;

use Doctrine\DBAL\Connection;

final class AdministrativeRecordDeletionService
{
    public function __construct(
        private readonly Connection $connection,
    ) {
    }

    public function deleteUser(int $id, string $login): void
    {
        $this->connection->transactional(function (Connection $connection) use ($id, $login): void {
            $this->deleteAttendances($connection, 'atendimentos', 'atendimentos_codificados', 'atendimentos_metadata', $id, true);
            $this->deleteAttendances($connection, 'historico_atendimentos', 'historico_atendimentos_codificados', 'historico_atendimentos_metadata', $id, true);

            $connection->executeStatement('DELETE FROM servicos_usuarios WHERE usuario_id = ?', [$id]);
            $connection->executeStatement('DELETE FROM lotacoes WHERE usuario_id = ?', [$id]);
            $connection->executeStatement('DELETE FROM usuarios_metadata WHERE usuario_id = ?', [$id]);
            $connection->executeStatement(
                'DELETE FROM oauth2_refresh_token WHERE access_token IN (SELECT identifier FROM oauth2_access_token WHERE user_identifier = ?)',
                [$login],
            );
            $connection->executeStatement('DELETE FROM oauth2_authorization_code WHERE user_identifier = ?', [$login]);
            $connection->executeStatement('DELETE FROM oauth2_access_token WHERE user_identifier = ?', [$login]);
            $connection->executeStatement('DELETE FROM usuarios WHERE id = ?', [$id]);
        });
    }

    public function deleteCustomer(int $id): void
    {
        $this->connection->transactional(function (Connection $connection) use ($id): void {
            $this->deleteAttendances($connection, 'atendimentos', 'atendimentos_codificados', 'atendimentos_metadata', $id, false);
            $this->deleteAttendances($connection, 'historico_atendimentos', 'historico_atendimentos_codificados', 'historico_atendimentos_metadata', $id, false);

            $connection->executeStatement('DELETE FROM agendamentos WHERE cliente_id = ?', [$id]);
            $connection->executeStatement('DELETE FROM clientes_metadata WHERE cliente_id = ?', [$id]);
            $connection->executeStatement('DELETE FROM clientes WHERE id = ?', [$id]);
        });
    }

    private function deleteAttendances(
        Connection $connection,
        string $table,
        string $codedTable,
        string $metadataTable,
        int $id,
        bool $user,
    ): void {
        $condition = $user ? '(usuario_id = ? OR usuario_tri_id = ?)' : 'cliente_id = ?';
        $parameters = $user ? [$id, $id] : [$id];
        $subquery = "SELECT id FROM {$table} WHERE {$condition}";

        $connection->executeStatement("DELETE FROM {$codedTable} WHERE atendimento_id IN ({$subquery})", $parameters);
        $connection->executeStatement("DELETE FROM {$metadataTable} WHERE atendimento_id IN ({$subquery})", $parameters);
        $connection->executeStatement(
            "UPDATE {$table} target INNER JOIN {$table} doomed ON target.atendimento_id = doomed.id "
            . "SET target.atendimento_id = NULL WHERE {$this->qualifiedCondition('doomed', $condition)}",
            $parameters,
        );

        if ($table === 'atendimentos') {
            $connection->executeStatement(
                "UPDATE {$table} target INNER JOIN {$table} doomed ON target.retorno_apos_id = doomed.id "
                . "SET target.retorno_apos_id = NULL WHERE {$this->qualifiedCondition('doomed', $condition)}",
                $parameters,
            );
        }

        $connection->executeStatement("DELETE FROM {$table} WHERE {$condition}", $parameters);
    }

    private function qualifiedCondition(string $alias, string $condition): string
    {
        return str_replace(
            ['usuario_id', 'usuario_tri_id', 'cliente_id'],
            ["{$alias}.usuario_id", "{$alias}.usuario_tri_id", "{$alias}.cliente_id"],
            $condition,
        );
    }
}
