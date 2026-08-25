<?php

declare(strict_types=1);

namespace App\Tests\Repository;

use App\Entity\Usuario;
use App\Repository\UsuarioRepository;
use App\Tests\TestHelper;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

final class UsuarioRepositoryTest extends KernelTestCase
{
    private EntityManagerInterface $em;

    protected function setUp(): void
    {
        self::bootKernel();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);
        $this->em->getConnection()->beginTransaction();
    }

    protected function tearDown(): void
    {
        $this->em->getConnection()->rollBack();
        parent::tearDown();
    }

    public function testRedirectTargetsRespectUnitActivityAndAttendanceProfile(): void
    {
        $unit = TestHelper::createUnidade($this->em, 'Redirect A');
        $otherUnit = TestHelper::createUnidade($this->em, 'Redirect B');
        $service = TestHelper::createServico($this->em, 'Redirect');
        $serviceUnit = TestHelper::linkServicoUnidade($this->em, $service, $unit);
        TestHelper::linkServicoUnidade($this->em, $service, $otherUnit);
        $attendance = TestHelper::createPerfil($this->em, 'Attendance', ['novosga.attendance']);
        $reception = TestHelper::createPerfil($this->em, 'Reception', ['novosga.triage']);

        $eligible = $this->createUser('eligible');
        TestHelper::linkUnidadeUsuario($this->em, $unit, $eligible, $attendance);
        TestHelper::linkServicoUsuario($this->em, $service, $unit, $eligible);

        $receptionist = $this->createUser('receptionist');
        TestHelper::linkUnidadeUsuario($this->em, $unit, $receptionist, $reception);
        TestHelper::linkServicoUsuario($this->em, $service, $unit, $receptionist);

        $wrongUnit = $this->createUser('wrong-unit');
        TestHelper::linkUnidadeUsuario($this->em, $unit, $wrongUnit, $attendance);
        TestHelper::linkServicoUsuario($this->em, $service, $otherUnit, $wrongUnit);

        $inactive = $this->createUser('inactive', false);
        TestHelper::linkUnidadeUsuario($this->em, $unit, $inactive, $attendance);
        TestHelper::linkServicoUsuario($this->em, $service, $unit, $inactive);

        $admin = $this->createUser('admin', true, true);
        TestHelper::linkServicoUsuario($this->em, $service, $unit, $admin);

        /** @var UsuarioRepository $repository */
        $repository = $this->em->getRepository(Usuario::class);
        $result = $repository->findByServicoUnidade($serviceUnit);
        $ids = array_map(static fn (Usuario $user) => $user->getId(), $result);

        self::assertContains($eligible->getId(), $ids);
        self::assertContains($admin->getId(), $ids);
        self::assertNotContains($receptionist->getId(), $ids);
        self::assertNotContains($wrongUnit->getId(), $ids);
        self::assertNotContains($inactive->getId(), $ids);
    }

    private function createUser(string $suffix, bool $active = true, bool $admin = false): Usuario
    {
        $user = (new Usuario())
            ->setLogin('r' . bin2hex(random_bytes(8)))
            ->setNome($suffix)
            ->setSobrenome('Test')
            ->setSenha('test')
            ->setAtivo($active)
            ->setAdmin($admin);
        $this->em->persist($user);
        $this->em->flush();

        return $user;
    }
}
