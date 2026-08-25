<?php

declare(strict_types=1);

namespace App\Tests\EventListener;

use App\Entity\Local;
use App\Entity\Unidade;
use App\Entity\Usuario;
use App\EventListener\AttendanceLocationLockListener;
use App\Repository\LocalRepository;
use Exception;
use Novosga\Entity\EntityMetadataInterface;
use Novosga\Event\PreUserSetLocalEvent;
use Novosga\Service\UsuarioServiceInterface;
use PHPUnit\Framework\MockObject\MockObject;
use PHPUnit\Framework\TestCase;

final class AttendanceLocationLockListenerTest extends TestCase
{
    private UsuarioServiceInterface&MockObject $usuarioService;
    private LocalRepository&MockObject $localRepository;
    private Usuario $usuario;
    private Unidade $unidade;

    protected function setUp(): void
    {
        $this->usuarioService = $this->createMock(UsuarioServiceInterface::class);
        $this->localRepository = $this->createMock(LocalRepository::class);
        $this->usuario = (new Usuario())->setId(1);
        $this->unidade = (new Unidade())->setId(1);
    }

    public function testAllowsChangingUnlockedLocationAndNumber(): void
    {
        $current = (new Local())->setId(1);
        $target = (new Local())->setId(2);
        $listener = $this->listener($current, 1, 10);

        $listener(new PreUserSetLocalEvent($this->unidade, $this->usuario, $target, 20, 'todos'));

        self::addToAssertionCount(1);
    }

    public function testBlocksChangingLockedLocation(): void
    {
        $current = (new Local())->setId(1)->setPermiteTrocarLocal(false);
        $target = (new Local())->setId(2);
        $listener = $this->listener($current, 1, 10);

        $this->expectException(Exception::class);
        $this->expectExceptionMessage('A troca de local está bloqueada');

        $listener(new PreUserSetLocalEvent($this->unidade, $this->usuario, $target, 10, 'todos'));
    }

    public function testBlocksChangingLockedNumber(): void
    {
        $current = (new Local())->setId(1)->setPermiteTrocarNumero(false);
        $listener = $this->listener($current, 1, 10);

        $this->expectException(Exception::class);
        $this->expectExceptionMessage('A troca do número da sala está bloqueada');

        $listener(new PreUserSetLocalEvent($this->unidade, $this->usuario, $current, 20, 'todos'));
    }

    private function listener(Local $current, int $localId, int $number): AttendanceLocationLockListener
    {
        $localMetadata = $this->createMock(EntityMetadataInterface::class);
        $localMetadata->method('getValue')->willReturn($localId);
        $numberMetadata = $this->createMock(EntityMetadataInterface::class);
        $numberMetadata->method('getValue')->willReturn($number);
        $this->usuarioService
            ->method('meta')
            ->willReturnCallback(
                static fn ($usuario, string $name) => $name === UsuarioServiceInterface::ATTR_ATENDIMENTO_LOCAL
                    ? $localMetadata
                    : $numberMetadata,
            );
        $this->localRepository->method('find')->with($localId)->willReturn($current);

        return new AttendanceLocationLockListener($this->usuarioService, $this->localRepository);
    }
}
