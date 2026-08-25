<?php

declare(strict_types=1);

namespace App\Service;

use Doctrine\DBAL\ArrayParameterType;
use Doctrine\DBAL\Connection;

final class AdministrativeRecordDeletionService
{
    public function __construct(
        private readonly Connection $connection,
    ) {
    }

    public function deleteUser(int $id): void
    {
        $this->connection->transactional(function (Connection $connection) use ($id): void {
            $login = $connection->fetchOne('SELECT login FROM usuarios WHERE id = ? FOR UPDATE', [$id]);
            if (!is_string($login)) {
                return;
            }

            $this->deleteAttendances(
                $connection,
                'atendimentos',
                'atendimentos_codificados',
                'atendimentos_metadata',
                $id,
                true,
            );
            $this->deleteAttendances(
                $connection,
                'historico_atendimentos',
                'historico_atendimentos_codificados',
                'historico_atendimentos_metadata',
                $id,
                true,
            );

            $connection->executeStatement('DELETE FROM servicos_usuarios WHERE usuario_id = ?', [$id]);
            $connection->executeStatement('DELETE FROM lotacoes WHERE usuario_id = ?', [$id]);
            $connection->executeStatement('DELETE FROM usuarios_metadata WHERE usuario_id = ?', [$id]);
            $connection->executeStatement(
                'DELETE FROM oauth2_refresh_token WHERE access_token IN '
                . '(SELECT identifier FROM oauth2_access_token WHERE user_identifier = ?)',
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
            $document = $connection->fetchOne('SELECT documento FROM clientes WHERE id = ? FOR UPDATE', [$id]);
            if (false === $document) {
                return;
            }

            $this->deleteAttendances(
                $connection,
                'atendimentos',
                'atendimentos_codificados',
                'atendimentos_metadata',
                $id,
                false,
            );
            $this->deleteAttendances(
                $connection,
                'historico_atendimentos',
                'historico_atendimentos_codificados',
                'historico_atendimentos_metadata',
                $id,
                false,
            );

            if (is_string($document) && '' !== $document) {
                $connection->executeStatement('DELETE FROM painel_senha WHERE documento_cliente = ?', [$document]);
            }
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
        $ids = $connection->fetchFirstColumn("SELECT id FROM {$table} WHERE {$condition}", $parameters);

        if ([] === $ids) {
            return;
        }

        $arrayType = [ArrayParameterType::INTEGER];
        $connection->executeStatement(
            "DELETE FROM {$codedTable} WHERE atendimento_id IN (?)",
            [$ids],
            $arrayType,
        );
        $connection->executeStatement(
            "DELETE FROM {$metadataTable} WHERE atendimento_id IN (?)",
            [$ids],
            $arrayType,
        );
        $connection->executeStatement(
            "UPDATE {$table} SET atendimento_id = NULL WHERE atendimento_id IN (?)",
            [$ids],
            $arrayType,
        );

        if ($table === 'atendimentos') {
            $connection->executeStatement(
                "UPDATE {$table} SET retorno_apos_id = NULL WHERE retorno_apos_id IN (?)",
                [$ids],
                $arrayType,
            );
        }

        $connection->executeStatement(
            "DELETE FROM {$table} WHERE id IN (?)",
            [$ids],
            $arrayType,
        );
    }
}
