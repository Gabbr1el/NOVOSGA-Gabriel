<?php

declare(strict_types=1);

namespace App\EventListener;

use App\Entity\Local;
use App\Repository\LocalRepository;
use Exception;
use Novosga\Event\PreUserSetLocalEvent;
use Novosga\Service\UsuarioServiceInterface;
use Symfony\Component\EventDispatcher\Attribute\AsEventListener;

#[AsEventListener(event: PreUserSetLocalEvent::class)]
final readonly class AttendanceLocationLockListener
{
    public function __construct(
        private UsuarioServiceInterface $usuarioService,
        private LocalRepository $localRepository,
    ) {
    }

    public function __invoke(PreUserSetLocalEvent $event): void
    {
        $localId = $this->usuarioService
            ->meta($event->usuario, UsuarioServiceInterface::ATTR_ATENDIMENTO_LOCAL)
            ?->getValue();
        $numero = $this->usuarioService
            ->meta($event->usuario, UsuarioServiceInterface::ATTR_ATENDIMENTO_NUM_LOCAL)
            ?->getValue();

        /** @var Local|null $localAtual */
        $localAtual = $localId ? $this->localRepository->find($localId) : null;
        if ($localAtual === null) {
            return;
        }

        if (!$localAtual->isPermiteTrocarLocal() && (int) $localId !== $event->local->getId()) {
            throw new Exception('A troca de local está bloqueada pela configuração do local atual.');
        }

        if (!$localAtual->isPermiteTrocarNumero() && (int) $numero !== (int) $event->numero) {
            throw new Exception('A troca do número da sala está bloqueada pela configuração do local atual.');
        }
    }
}
