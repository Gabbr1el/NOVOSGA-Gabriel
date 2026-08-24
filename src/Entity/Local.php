<?php

declare(strict_types=1);

/*
 * This file is part of the NovoSGA project.
 *
 * (c) Rogerio Lino <rogeriolino@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace App\Entity;

use App\EventListener\LocalListener;
use App\EventListener\TimestampableEntityListener;
use App\Repository\LocalRepository;
use Doctrine\ORM\Mapping as ORM;
use Novosga\Entity\LocalInterface;

/**
 * Local de atendimento
 *
 * @author Rogerio Lino <rogeriolino@gmail.com>
 */
#[ORM\Entity(repositoryClass: LocalRepository::class)]
#[ORM\EntityListeners([
    TimestampableEntityListener::class,
    LocalListener::class,
])]
#[ORM\Table(name: 'locais')]
class Local implements TimestampableEntityInterface, LocalInterface
{
    use TimestampableEntityTrait;

    #[ORM\Id]
    #[ORM\Column]
    #[ORM\GeneratedValue(strategy: 'IDENTITY')]
    #[ORM\SequenceGenerator(sequenceName: "locais_id_seq", allocationSize: 1, initialValue: 1)]
    protected ?int $id = null;

    #[ORM\Column(length: 20, unique: true)]
    private ?string $nome = null;

    #[ORM\Column(options: ['default' => true])]
    private bool $permiteTrocarLocal = true;

    #[ORM\Column(options: ['default' => true])]
    private bool $permiteTrocarNumero = true;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function setId(?int $id): static
    {
        $this->id = $id;

        return $this;
    }

    public function setNome(?string $nome): static
    {
        $this->nome = $nome;

        return $this;
    }

    public function getNome(): ?string
    {
        return $this->nome;
    }

    public function isPermiteTrocarLocal(): bool
    {
        return $this->permiteTrocarLocal;
    }

    public function setPermiteTrocarLocal(bool $permiteTrocarLocal): static
    {
        $this->permiteTrocarLocal = $permiteTrocarLocal;

        return $this;
    }

    public function isPermiteTrocarNumero(): bool
    {
        return $this->permiteTrocarNumero;
    }

    public function setPermiteTrocarNumero(bool $permiteTrocarNumero): static
    {
        $this->permiteTrocarNumero = $permiteTrocarNumero;

        return $this;
    }

    public function __toString()
    {
        return $this->getNome();
    }

    /** @return array<string,mixed> */
    public function jsonSerialize(): array
    {
        return [
            'id' => $this->getId(),
            'nome' => $this->getNome(),
            'permiteTrocarLocal' => $this->isPermiteTrocarLocal(),
            'permiteTrocarNumero' => $this->isPermiteTrocarNumero(),
            'createdAt' => $this->getCreatedAt()?->format('Y-m-d\TH:i:s'),
            'updatedAt' => $this->getUpdatedAt()?->format('Y-m-d\TH:i:s'),
        ];
    }
}
