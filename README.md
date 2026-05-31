# tank-shooter-expo-tech
Jogo de combate de tanques em 2D na Godot 4. Desenvolvido para a ExpoTech com foco em IA para bots, física e modos competitivos PvP e Coop local (Melhor de 5). Suporta execução Web e PC. Inclui tela de instruções integrada.


# 🎮 Tank Shooter - ExpoTech Edition

![Godot Engine](https://img.shields.io/badge/Godot_Engine-4.x-blue?logo=godot-engine&logoColor=white)
![Language](https://img.shields.io/badge/Language-GDScript-emerald)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20PC-orange)

Uma arena de combate tático de tanques em 2D com física apurada, múltiplos modos de jogo e inteligência artificial adaptativa. Projeto acadêmico desenvolvido na **Godot Engine 4** para apresentação na **ExpoTech**.

---

## 🚀 Links do Projeto

* 🕹️ **[Clique aqui para Jogar direto no Navegador (Itch.io)](https://hakeemoloye.itch.io/tank-shooter)**
* 📺 **[Assista ao Vídeo de Apresentação / Pitch no YouTube](COLE_AQUI_O_LINK_DO_SEU_VIDEO_DO_YOUTUBE)**

---

## ✨ Funcionalidades Principais

* **⚔️ Três Modos de Jogo Dinâmicos:**
    * **Player vs Player (PvP):** Combate tático local com comandos divididos no mesmo teclado.
    * **Solo vs Bots:** Treino de movimentação e combate contra tanques inimigos controlados por IA.
    * **Coop vs Bots:** Cooperação local para dois jogadores enfrentarem juntos as hordas de tanques robôs.
* **🏆 Sistema Competitivo MD5 (Melhor de 5):** Lógica customizada de gerenciamento de rodadas. A partida se estende dinamicamente por até 5 rounds, onde a primeira equipe ou jogador a conquistar 3 pontos vence.
* **🧠 Inteligência Artificial (Bots):** Inimigos autônomos que rastreiam a posição do alvo mais próximo, analisam o mapa para evitar colisões persistentes e efetuam disparos preditivos.
* **⏱️ Instruções Just-in-Time:** Uma tela interna de introdução exibe o mapa de controles por 5 segundos antes de inicializar o cenário principal, melhorando a experiência do usuário.

---

## 🛠️ Arquitetura e Engenharia do Código

O desenvolvimento priorizou o desacoplamento de sistemas e padrões recomendados para arquiteturas de jogos na Godot 4:

* **GameManager (Singleton):** Nó global responsável pela persistência dos placares, gerenciamento do ciclo de vida dos rounds (usando corrotinas com `await` e sinais) e invocação assíncrona das telas de transição e Game Over.
* **Componentização de Cenas:** Separação estrita de entidades em subcenas (`player.tscn`, `projectile.tscn`), permitindo reaproveitamento total da lógica física e de partículas de explosão entre jogadores e robôs.
* **Interface (HUD) Dinâmica:** Processamento otimizado que altera os labels de pontuação e o contador de rounds (calculado com base na soma histórica de pontos) dependendo do modo selecionado no menu principal.

---

## 🎮 Controles

O jogo possui suporte completo a teclado e mapeamento automático para comandos **PlayStation 5 (DualSense)** para uma experiência de consola local:

### 🔵 Jogador 1 (Tanque Azul)
* **⌨️ Teclado:** Movimentação em `W`, `A`, `S`, `D` | Atirar em `Espaço`
* **🎮 Comando PS5:** Movimentação no `Analógico Esquerdo e direito`| Atirar no botão `R2`

### 🔴 Jogador 2 / Coop (Tanque Vermelho)
* **⌨️ Teclado:** Movimentação nas Setas (`⬆`, `⬇`, `⬅`, `➡️`) | Atirar em `Enter`
* **🎮 Comando PS5 (Segundo Comando):** Movimentação no `Analógico Esquerdo e direito` | Atirar no botão `R2`

---

## 💻 Como Rodar o Código Localmente

1. Baixe e instale a **Godot Engine v4.x** (versão Standard).
2. Clone este repositório em sua máquina:
   ```bash
   git clone [https://github.com/Hakeemoloye/tank-shooter-expo-tech.git](https://github.com/Hakeemoloye/tank-shooter-expo-tech.git)
