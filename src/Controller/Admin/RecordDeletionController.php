<?php

declare(strict_types=1);

namespace App\Controller\Admin;

use App\Entity\Cliente;
use App\Entity\Usuario;
use App\Service\AdministrativeRecordDeletionService;
use Novosga\Entity\UsuarioInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

#[Route('/admin/records', name: 'admin_records_')]
final class RecordDeletionController extends AbstractController
{
    public function __construct(
        private readonly AdministrativeRecordDeletionService $deletionService,
    ) {
    }

    #[Route('/users/{id}/delete', name: 'user_delete', methods: ['POST'])]
    public function deleteUser(Request $request, Usuario $usuario): Response
    {
        /** @var UsuarioInterface $currentUser */
        $currentUser = $this->getUser();

        if (!$this->isCsrfTokenValid('delete-user-' . $usuario->getId(), (string) $request->request->get('_token'))) {
            throw $this->createAccessDeniedException('Token de confirmação inválido.');
        }

        if ($currentUser->getId() === $usuario->getId()) {
            $this->addFlash('error', 'Você não pode apagar o usuário da sua própria sessão.');

            return $this->redirectToRoute('novosga_users_edit', ['id' => $usuario->getId()]);
        }

        $this->deletionService->deleteUser((int) $usuario->getId());
        $this->addFlash('success', 'Usuário e todos os registros vinculados foram apagados definitivamente.');

        return $this->redirectToRoute('novosga_users_index');
    }

    #[Route('/customers/{id}/delete', name: 'customer_delete', methods: ['POST'])]
    public function deleteCustomer(Request $request, Cliente $cliente): Response
    {
        $validToken = $this->isCsrfTokenValid(
            'delete-customer-' . $cliente->getId(),
            (string) $request->request->get('_token'),
        );
        if (!$validToken) {
            throw $this->createAccessDeniedException('Token de confirmação inválido.');
        }

        $this->deletionService->deleteCustomer((int) $cliente->getId());
        $this->addFlash('success', 'Paciente e todos os registros vinculados foram apagados definitivamente.');

        return $this->redirectToRoute('novosga_customers_index');
    }
}
