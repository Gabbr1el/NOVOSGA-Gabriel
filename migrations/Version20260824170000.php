<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Platforms\MySQLPlatform;
use Doctrine\DBAL\Platforms\PostgreSQLPlatform;
use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;
use Doctrine\Migrations\Exception\AbortMigration;

final class Version20260824170000 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Add independent location and room-number change permissions to attendance places';
    }

    public function up(Schema $schema): void
    {
        if ($this->platform instanceof MySQLPlatform) {
            $this->addSql('ALTER TABLE locais ADD permite_trocar_local TINYINT(1) DEFAULT 1 NOT NULL, ADD permite_trocar_numero TINYINT(1) DEFAULT 1 NOT NULL');
        } elseif ($this->platform instanceof PostgreSQLPlatform) {
            $this->addSql('ALTER TABLE locais ADD permite_trocar_local BOOLEAN DEFAULT TRUE NOT NULL, ADD permite_trocar_numero BOOLEAN DEFAULT TRUE NOT NULL');
        } else {
            throw new AbortMigration(sprintf('Unsupported database platform: %s', get_class($this->platform)));
        }
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE locais DROP permite_trocar_local, DROP permite_trocar_numero');
    }
}
