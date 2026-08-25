<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Platforms\MySQLPlatform;
use Doctrine\DBAL\Platforms\PostgreSQLPlatform;
use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;
use Doctrine\Migrations\Exception\AbortMigration;

final class Version20260825120000 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Anchor a deferred attendance immediately after the next queued ticket';
    }

    public function up(Schema $schema): void
    {
        if ($this->platform instanceof MySQLPlatform) {
            $this->addSql('ALTER TABLE atendimentos ADD retorno_apos_id INT DEFAULT NULL');
            $this->addSql(
                'ALTER TABLE atendimentos ADD CONSTRAINT FK_29E906E7B641063 '
                . 'FOREIGN KEY (retorno_apos_id) REFERENCES atendimentos (id) ON DELETE SET NULL'
            );
            $this->addSql('CREATE INDEX IDX_29E906E7B641063 ON atendimentos (retorno_apos_id)');
        } elseif ($this->platform instanceof PostgreSQLPlatform) {
            $this->addSql('ALTER TABLE atendimentos ADD retorno_apos_id INT DEFAULT NULL');
            $this->addSql(
                'ALTER TABLE atendimentos ADD CONSTRAINT FK_29E906E7B641063 '
                . 'FOREIGN KEY (retorno_apos_id) REFERENCES atendimentos (id) '
                . 'ON DELETE SET NULL NOT DEFERRABLE INITIALLY IMMEDIATE'
            );
            $this->addSql('CREATE INDEX IDX_29E906E7B641063 ON atendimentos (retorno_apos_id)');
        } else {
            throw new AbortMigration(sprintf('Unsupported database platform: %s', get_class($this->platform)));
        }
    }

    public function down(Schema $schema): void
    {
        if ($this->platform instanceof MySQLPlatform) {
            $this->addSql('ALTER TABLE atendimentos DROP FOREIGN KEY FK_29E906E7B641063');
            $this->addSql('DROP INDEX IDX_29E906E7B641063 ON atendimentos');
            $this->addSql('ALTER TABLE atendimentos DROP retorno_apos_id');
        } elseif ($this->platform instanceof PostgreSQLPlatform) {
            $this->addSql('ALTER TABLE atendimentos DROP CONSTRAINT FK_29E906E7B641063');
            $this->addSql('DROP INDEX IDX_29E906E7B641063');
            $this->addSql('ALTER TABLE atendimentos DROP retorno_apos_id');
        } else {
            throw new AbortMigration(sprintf('Unsupported database platform: %s', get_class($this->platform)));
        }
    }
}
