<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Platforms\MySQLPlatform;
use Doctrine\DBAL\Platforms\PostgreSQLPlatform;
use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;
use Doctrine\Migrations\Exception\AbortMigration;

final class Version20260825130000 extends AbstractMigration
{
    private const OLD_INDEX = 'IDX_29E906E7B641063';
    private const NEW_INDEX = 'IDX_29E906E7EA4BA547';

    public function getDescription(): string
    {
        return 'Align the deferred attendance index name with Doctrine metadata';
    }

    public function up(Schema $schema): void
    {
        $this->renameIndex(self::OLD_INDEX, self::NEW_INDEX);
    }

    public function down(Schema $schema): void
    {
        $this->renameIndex(self::NEW_INDEX, self::OLD_INDEX);
    }

    private function renameIndex(string $from, string $to): void
    {
        if ($this->platform instanceof MySQLPlatform) {
            $this->addSql(sprintf('ALTER TABLE atendimentos RENAME INDEX %s TO %s', $from, $to));
        } elseif ($this->platform instanceof PostgreSQLPlatform) {
            $this->addSql(sprintf('ALTER INDEX %s RENAME TO %s', $from, $to));
        } else {
            throw new AbortMigration(sprintf('Unsupported database platform: %s', get_class($this->platform)));
        }
    }
}
