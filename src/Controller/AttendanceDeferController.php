<?php

declare(strict_types=1);

namespace App\Controller;

use App\Service\AtendimentoService;
use Novosga\Entity\UsuarioInterface;
use Novosga\Http\Envelope;
use Novosga\Service\FilaServiceInterface;
use Novosga\Service\UsuarioServiceInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class AttendanceDeferController extends AbstractController
{
    #[Route('/novosga.attendance/adiar', name: 'attendance_defer', methods: ['POST'])]
    public function __invoke(
        AtendimentoService $atendimentoService,
        UsuarioServiceInterface $usuarioService,
    ): Response {
        /** @var UsuarioInterface $usuario */
        $usuario = $this->getUser();
        $unidade = $usuario->getLotacao()->getUnidade();
        $atual = $atendimentoService->getAtendimentoAndamento($usuario, $unidade);
        if ($atual === null) {
            throw $this->createNotFoundException('Nenhum atendimento em andamento.');
        }

        $tipoMeta = $usuarioService->meta($usuario, UsuarioServiceInterface::ATTR_ATENDIMENTO_TIPO);
        $tipo = $tipoMeta?->getValue() ?? FilaServiceInterface::TIPO_TODOS;
        $servicos = $usuarioService->getServicosUnidade($usuario, $unidade);
        $novo = $atendimentoService->adiarAtendimento($atual, $usuario, $servicos, $tipo);

        return $this->json(new Envelope($novo->jsonSerialize()));
    }
}
