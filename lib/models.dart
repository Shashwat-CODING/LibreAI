enum ModelCategory { text, vision, imageGen }

class AIModel {
  final String id;
  final String name;
  final String description;
  final String provider;
  final ModelCategory category;

  const AIModel({
    required this.id,
    required this.name,
    required this.description,
    required this.provider,
    required this.category,
  });
}

const List<AIModel> availableModels = [
  // Multimodal & Vision Models
  AIModel(
    id: '@cf/moonshotai/kimi-k2.7-code',
    name: 'Kimi K2.7 Code',
    description: 'Moonshot AI 1T parameter frontier model with vision & agentic coding.',
    provider: 'Cloudflare',
    category: ModelCategory.vision,
  ),
  AIModel(
    id: '@cf/meta/llama-4-scout-17b-16e-instruct',
    name: 'Llama 4 Scout 17B (Vision)',
    description: 'Meta Llama 4 natively multimodal text & image understanding.',
    provider: 'Cloudflare',
    category: ModelCategory.vision,
  ),
  AIModel(
    id: '@cf/meta/llama-3.2-11b-vision-instruct',
    name: 'Llama 3.2 11B Vision',
    description: 'Meta instruction-tuned model for image analysis & visual reasoning.',
    provider: 'Cloudflare',
    category: ModelCategory.vision,
  ),
  AIModel(
    id: '@cf/mistralai/mistral-small-3.1-24b-instruct',
    name: 'Mistral Small 3.1 24B (Vision)',
    description: 'State-of-the-art vision understanding with 128k context window.',
    provider: 'Cloudflare',
    category: ModelCategory.vision,
  ),

  // LLM Text & Reasoning Models
  AIModel(
    id: '@cf/meta/llama-3.3-70b-instruct',
    name: 'Llama 3.3 70B',
    description: 'Meta flagship open model. Reasoning & coding excellence.',
    provider: 'Cloudflare',
    category: ModelCategory.text,
  ),
  AIModel(
    id: '@cf/deepseek-ai/deepseek-r1-distill-qwen-32b',
    name: 'DeepSeek R1 32B',
    description: 'Advanced reasoning and step-by-step thinking.',
    provider: 'Cloudflare',
    category: ModelCategory.text,
  ),
  AIModel(
    id: '@cf/qwen/qwq-32b',
    name: 'QwQ 32B Reasoning',
    description: 'Qwen reasoning model designed for complex problem solving.',
    provider: 'Cloudflare',
    category: ModelCategory.text,
  ),
  AIModel(
    id: '@cf/qwen/qwen2.5-coder-32b-instruct',
    name: 'Qwen 2.5 Coder 32B',
    description: 'Specialized code generation & instruction following.',
    provider: 'Cloudflare',
    category: ModelCategory.text,
  ),
  AIModel(
    id: '@cf/zhipuai/glm-4.7-flash',
    name: 'GLM 4.7 Flash',
    description: 'Zhipu AI fast multilingual dialogue & tool calling model.',
    provider: 'Cloudflare',
    category: ModelCategory.text,
  ),
  AIModel(
    id: '@cf/meta/llama-3.1-8b-instruct-fp8',
    name: 'Llama 3.1 8B FP8',
    description: 'Fast, high-efficiency lightweight model.',
    provider: 'Cloudflare',
    category: ModelCategory.text,
  ),

  // Image Generation Models
  AIModel(
    id: '@cf/black-forest-labs/flux-2-klein-4b',
    name: 'FLUX.2 Klein 4B (Default)',
    description: 'Black Forest Labs ultra-fast distilled image model (steps:25, 1024x1024).',
    provider: 'Cloudflare',
    category: ModelCategory.imageGen,
  ),
  AIModel(
    id: '@cf/blackforestlabs/flux-1-schnell',
    name: 'FLUX.1 Schnell',
    description: 'Black Forest Labs 12B rectified flow text-to-image generator.',
    provider: 'Cloudflare',
    category: ModelCategory.imageGen,
  ),
  AIModel(
    id: '@cf/bytedance/stable-diffusion-xl-lightning',
    name: 'SDXL Lightning',
    description: 'ByteDance lightning-fast 1024px text-to-image generator.',
    provider: 'Cloudflare',
    category: ModelCategory.imageGen,
  ),
  AIModel(
    id: '@cf/stabilityai/stable-diffusion-xl-base-1.0',
    name: 'SDXL Base 1.0',
    description: 'Stability AI diffusion-based text-to-image model.',
    provider: 'Cloudflare',
    category: ModelCategory.imageGen,
  ),
];
