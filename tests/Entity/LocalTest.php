<?php

declare(strict_types=1);

namespace App\Tests\Entity;

use App\Entity\Local;
use PHPUnit\Framework\TestCase;

final class LocalTest extends TestCase
{
    public function testChangePermissionsAreEnabledByDefaultAndSerialized(): void
    {
        $local = (new Local())->setNome('Sala');

        self::assertTrue($local->isPermiteTrocarLocal());
        self::assertTrue($local->isPermiteTrocarNumero());
        self::assertTrue($local->jsonSerialize()['permiteTrocarLocal']);
        self::assertTrue($local->jsonSerialize()['permiteTrocarNumero']);
    }

    public function testChangePermissionsCanBeConfiguredIndependently(): void
    {
        $local = (new Local())
            ->setPermiteTrocarLocal(false)
            ->setPermiteTrocarNumero(true);

        self::assertFalse($local->isPermiteTrocarLocal());
        self::assertTrue($local->isPermiteTrocarNumero());
    }
}
