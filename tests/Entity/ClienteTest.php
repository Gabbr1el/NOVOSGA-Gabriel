<?php

declare(strict_types=1);

namespace App\Tests\Entity;

use App\Entity\Cliente;
use PHPUnit\Framework\TestCase;
use ReflectionProperty;
use Symfony\Component\Validator\Constraints\Regex;
use Symfony\Component\Validator\Validation;

final class ClienteTest extends TestCase
{
    public function testNormalizesFormattedCpf(): void
    {
        $cliente = (new Cliente())->setDocumento('123.456.789-01');

        self::assertSame('12345678901', $cliente->getDocumento());
    }

    public function testRequiresExactlyElevenDigits(): void
    {
        $property = new ReflectionProperty(Cliente::class, 'documento');
        $constraint = $property->getAttributes(Regex::class)[0]->newInstance();
        $validator = Validation::createValidator();

        self::assertCount(1, $validator->validate('1234567890', $constraint));
        self::assertCount(1, $validator->validate('123456789012', $constraint));
        self::assertCount(0, $validator->validate('12345678901', $constraint));
    }
}
