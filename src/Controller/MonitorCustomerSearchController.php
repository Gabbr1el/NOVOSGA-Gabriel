<?php

declare(strict_types=1);

namespace App\Controller;

use App\Repository\AtendimentoRepository;
use Novosga\Entity\UsuarioInterface;
use Novosga\Http\Envelope;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class MonitorCustomerSearchController extends AbstractController
{
    #[Route('/novosga.monitor/buscar-paciente', name: 'monitor_customer_search', methods: ['GET'])]
    public function __invoke(Request $request, AtendimentoRepository $repository): Response
    {
        $nome = str_replace(['%', '_'], '', trim((string) $request->query->get('nome', '')));
        $cpf = preg_replace('/\D+/', '', (string) $request->query->get('cpf', ''));

        if ($nome === '' && $cpf === '') {
            return $this->json(new Envelope([]));
        }

        /** @var UsuarioInterface $usuario */
        $usuario = $this->getUser();
        $unidade = $usuario->getLotacao()->getUnidade();
        $atendimentos = $repository->findIssuedByCustomer($unidade, $nome, $cpf);

        $resultados = array_map(static function ($atendimento): array {
            $data = $atendimento->jsonSerialize();

            return [
                'id' => $data['id'],
                'senha' => $data['senha'],
                'servico' => $data['servico'],
                'dataChegada' => $data['dataChegada'],
                'status' => $data['status'],
                'cliente' => [
                    'nome' => $data['cliente']['nome'],
                    'documento' => $data['cliente']['documento'],
                ],
            ];
        }, $atendimentos);

        return $this->json(new Envelope($resultados));
    }
}
