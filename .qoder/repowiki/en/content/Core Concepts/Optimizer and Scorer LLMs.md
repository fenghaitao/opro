# Optimizer and Scorer LLMs

<cite>
**Referenced Files in This Document**
- [README.md](file://README.md)
- [opt_utils.py](file://opro/optimization/opt_utils.py)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py)
- [prompt_utils.py](file://opro/prompt_utils.py)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py)
- [eval_utils.py](file://opro/evaluation/eval_utils.py)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Component Analysis](#detailed-component-analysis)
6. [Dependency Analysis](#dependency-analysis)
7. [Performance Considerations](#performance-considerations)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Conclusion](#conclusion)
10. [Appendices](#appendices)

## Introduction
This document explains the distinct roles of optimizer and scorer LLMs in the opro system and how they collaborate in a feedback loop to evolve high-performing instructions. The optimizer LLM (e.g., GPT-3.5-turbo, text-bison) generates new candidate instructions by analyzing historical instruction-score pairs. The scorer LLM evaluates the performance of these instructions on benchmark tasks. The system orchestrates this process through configurable functions and parameters, including optimizer_llm_name and scorer_llm_dict, enabling flexible model selection and robust API handling.

## Project Structure
The opro system organizes functionality around:
- Optimization pipeline: constructs meta-prompts, invokes optimizer, and manages evolution loops.
- Evaluation pipeline: evaluates instructions with a scorer LLM and computes accuracy metrics.
- Prompt utilities: wraps OpenAI and Google Cloud model APIs with resilient invocation and retry logic.
- CLI entry points: scripts to run optimization and evaluation with model and dataset configuration.

```mermaid
graph TB
subgraph "Optimization"
OI["optimize_instructions.py"]
OU["opt_utils.py"]
end
subgraph "Evaluation"
EI["evaluate_instructions.py"]
EU["eval_utils.py"]
end
PU["prompt_utils.py"]
OI --> OU
OI --> PU
EI --> EU
EI --> PU
OU --> PU
EU --> PU
```

**Diagram sources**
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L1-L120)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L1-L120)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L1-L120)
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L1-L120)
- [prompt_utils.py](file://opro/prompt_utils.py#L1-L60)

**Section sources**
- [README.md](file://README.md#L25-L52)

## Core Components
- Optimizer LLM role:
  - Generates new instructions by analyzing historical instruction-score pairs.
  - Uses meta-prompts tailored to model type and instruction placement.
  - Invoked via call_optimizer_server_func with model-specific parameters.
- Scorer LLM role:
  - Evaluates instructions on benchmark tasks and returns accuracy metrics.
  - Handles multiple datasets and formats, with robust extraction and parsing logic.
  - Invoked via call_scorer_server_func with model-specific parameters.
- Feedback loop:
  - Initial instructions are scored, then new candidates are generated and scored iteratively.
  - Historical performance informs future meta-prompts and selection criteria.

Key configuration parameters:
- optimizer_llm_name: selects the optimizer model family (e.g., GPT-3.5-turbo, text-bison).
- scorer_llm_dict: encapsulates model type and serving parameters (e.g., temperature, batch size, num_servers).
- run_evolution kwargs: orchestrates the end-to-end process, including thresholds, sampling, and evaluation intervals.

**Section sources**
- [opt_utils.py](file://opro/optimization/opt_utils.py#L90-L120)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L338-L426)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L338-L400)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L238-L303)
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L536-L760)

## Architecture Overview
The system separates concerns between optimizer and scorer:
- Optimizer path: meta-prompt construction -> call_optimizer_server_func -> instruction extraction -> scoring pipeline.
- Scoring path: instruction evaluation -> raw answer collection -> final answer extraction -> accuracy computation.

```mermaid
sequenceDiagram
participant CLI as "optimize_instructions.py"
participant OU as "opt_utils.run_evolution"
participant PUO as "prompt_utils.call_*_server_func (optimizer)"
participant PUS as "prompt_utils.call_*_server_func (scorer)"
participant EU as "eval_utils.evaluate_single_instruction"
participant DS as "Dataset"
CLI->>OU : "Initialize with optimizer_llm_name, scorer_llm_dict, kwargs"
OU->>DS : "Load data and indices"
OU->>OU : "Generate meta-prompt"
OU->>PUO : "call_optimizer_server_func(meta_prompt)"
PUO-->>OU : "Raw outputs"
OU->>OU : "Extract new instructions"
OU->>EU : "Evaluate instructions (call_scorer_server_func)"
EU->>PUS : "Call scorer API"
PUS-->>EU : "Model outputs"
EU-->>OU : "Accuracy metrics"
OU-->>CLI : "Iterative improvement"
```

**Diagram sources**
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L338-L400)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L692-L799)
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L536-L760)
- [prompt_utils.py](file://opro/prompt_utils.py#L21-L133)

## Detailed Component Analysis

### Optimizer LLM: Generation and Meta-Prompts
- Meta-prompt construction:
  - gen_meta_prompt builds contextual prompts combining historical instruction-score pairs and optional few-shot QA exemplars.
  - Model-aware formatting distinguishes GPT vs text-bison prompts and instruction positions (before_Q, Q_begin, Q_end, A_begin).
- Instruction generation:
  - run_evolution calls call_optimizer_server_func with temperature scheduling and batch decoding.
  - Extracts new instructions from model outputs using model-specific delimiters or tag parsing.
- Few-shot exemplars:
  - Selects problematic or frequent wrong questions to guide refinement.
  - Supports multiple selection criteria (accumulative/current/fixed/random).

```mermaid
flowchart TD
Start(["Start Step i"]) --> BuildMeta["Build meta-prompt<br/>with history and exemplars"]
BuildMeta --> CallOpt["call_optimizer_server_func(meta_prompt)"]
CallOpt --> Extract["Extract new instructions"]
Extract --> Filter["Filter duplicates and thresholds"]
Filter --> Evaluate["Evaluate on training/validation"]
Evaluate --> Update["Update historical pool"]
Update --> Next{"More steps?"}
Next --> |Yes| BuildMeta
Next --> |No| End(["End"])
```

**Diagram sources**
- [opt_utils.py](file://opro/optimization/opt_utils.py#L90-L120)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L692-L799)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L732-L783)

**Section sources**
- [opt_utils.py](file://opro/optimization/opt_utils.py#L90-L120)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L692-L799)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L732-L783)

### Scorer LLM: Evaluation and Metrics
- Evaluation pipeline:
  - evaluate_single_instruction composes prompts, invokes scorer, and parses results.
  - Supports parallel prompting, second-round answer extraction, and normalization.
- Accuracy computation:
  - Robust matching logic covers exact match, choice text inclusion, Boolean symbols, and adaptive numeric/boolean treatment.
- Dataset-specific handling:
  - Formats vary by dataset (MMLU, BBH, GSM8K, MultiArith, AQuA) with appropriate true-answer fetching and prompt templates.

```mermaid
sequenceDiagram
participant EU as "eval_utils.evaluate_single_instruction"
participant PU as "prompt_utils.call_*_server_func"
participant DS as "Dataset"
EU->>DS : "Fetch true answers and indices"
EU->>EU : "Generate prompts per example"
EU->>PU : "Call scorer API (parallel or serial)"
PU-->>EU : "Raw answers"
EU->>EU : "Second-round extraction (optional)"
EU->>EU : "Normalize and parse predictions"
EU-->>EU : "Compute accuracy per example"
```

**Diagram sources**
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L536-L760)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L673-L745)

**Section sources**
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L536-L760)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L238-L303)

### API Invocation Patterns: call_optimizer_server_func and call_scorer_server_func
- Optimizer invocation:
  - optimize_instructions.py configures call_optimizer_server_func for GPT or text-bison with model-specific parameters (temperature, max_decode_steps, batch_size).
  - Tests the optimizer endpoint and prints outputs.
- Scorer invocation:
  - optimize_instructions.py configures call_scorer_server_func similarly for GPT or text-bison.
  - evaluate_instructions.py also configures and tests the scorer endpoint.
- Both rely on prompt_utils wrappers for resilience:
  - call_openai_server_func and call_palm_server_from_cloud handle timeouts, rate limits, and service errors with retries and sleep-backoff.

```mermaid
sequenceDiagram
participant OI as "optimize_instructions.py"
participant PU as "prompt_utils.py"
participant S as "Scorer API"
participant OP as "Optimizer API"
OI->>PU : "call_openai_server_func / call_palm_server_from_cloud"
PU->>S : "POST request"
S-->>PU : "Response or error"
PU-->>OI : "Outputs or retry"
OI->>PU : "call_openai_server_func / call_palm_server_from_cloud"
PU->>OP : "POST request"
OP-->>PU : "Response or error"
PU-->>OI : "Outputs or retry"
```

**Diagram sources**
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L338-L400)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L238-L303)
- [prompt_utils.py](file://opro/prompt_utils.py#L21-L133)

**Section sources**
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L338-L400)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L238-L303)
- [prompt_utils.py](file://opro/prompt_utils.py#L21-L133)

### Configuration Parameters and Their Impact
- optimizer_llm_name:
  - Determines meta-prompt formatting and instruction extraction logic.
  - Controls temperature scheduling and decoding parameters during generation.
- scorer_llm_dict:
  - Encapsulates model type and serving parameters (temperature, batch_size, num_servers).
  - Influences evaluation throughput and accuracy stability.
- run_evolution kwargs:
  - old_instruction_score_threshold: filters low-performing historical instructions.
  - num_generated_instructions_in_each_step: controls exploration breadth.
  - few_shot_selection_criteria: shapes meta-prompts to focus on hard examples.
  - meta_prompt_type and instruction_pos: tailor how instructions are embedded in prompts.

Impact on optimization effectiveness:
- Higher optimizer temperature increases diversity but may reduce coherence.
- Larger batch sizes improve throughput but increase API costs.
- Few-shot exemplars grounded in frequent wrong answers improve targeted refinement.

**Section sources**
- [opt_utils.py](file://opro/optimization/opt_utils.py#L90-L120)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L338-L426)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L732-L783)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L682-L740)

## Dependency Analysis
- Coupling:
  - optimize_instructions.py depends on opt_utils.py for orchestration and prompt construction.
  - Both pipelines depend on prompt_utils.py for API resilience and on eval_utils.py for evaluation.
- Cohesion:
  - opt_utils.py centralizes meta-prompt building and evolution logic.
  - eval_utils.py centralizes evaluation and metric computation.
- External dependencies:
  - OpenAI and Google Generative AI SDKs for model APIs.
  - Abseil flags for CLI configuration.

```mermaid
graph LR
OI["optimize_instructions.py"] --> OU["opt_utils.py"]
OI --> PU["prompt_utils.py"]
EI["evaluate_instructions.py"] --> EU["eval_utils.py"]
EI --> PU
OU --> PU
EU --> PU
```

**Diagram sources**
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L1-L120)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L1-L120)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L1-L120)
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L1-L120)
- [prompt_utils.py](file://opro/prompt_utils.py#L1-L60)

**Section sources**
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L1-L120)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L1-L120)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L1-L120)
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L1-L120)
- [prompt_utils.py](file://opro/prompt_utils.py#L1-L60)

## Performance Considerations
- API cost control:
  - Reduce num_decodes, batch_size, and num_servers where feasible.
  - Limit num_generated_instructions_in_each_step and num_search_steps.
- Throughput tuning:
  - Increase batch_size and num_servers cautiously; ensure model serving configs match.
  - Use parallel evaluation where supported (avoid for GPT models per evaluation settings).
- Stability:
  - Lower scorer temperature to reduce variance in evaluations.
  - Use fewer few-shot exemplars to speed up meta-prompt generation.

[No sources needed since this section provides general guidance]

## Troubleshooting Guide
Common issues and remedies:
- API rate limits and timeouts:
  - prompt_utils.py wraps OpenAI and Google Cloud calls with retry-on-error logic and sleep-backoff.
  - Tune max_retry and sleep_time in evaluation utilities to handle transient failures.
- Model availability:
  - Ensure API keys are configured for selected models (OpenAI or Google).
  - Verify model names and supported generations in prompt_utils.py.
- Output parsing:
  - For GPT models, final answer extraction may require second-round prompting and LaTeX box parsing.
  - For text-bison, ensure meta-prompt formatting matches expected square-bracket outputs.

Best practices:
- Start with conservative hyperparameters and scale gradually.
- Monitor API costs and adjust batch sizes accordingly.
- Prefer fewer, high-quality few-shot exemplars over large sets.

**Section sources**
- [prompt_utils.py](file://opro/prompt_utils.py#L21-L133)
- [eval_utils.py](file://opro/evaluation/eval_utils.py#L338-L379)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L296-L303)

## Conclusion
The opro system leverages optimizer and scorer LLMs in a complementary manner: the optimizer explores new instruction variants guided by historical performance, while the scorer provides reliable accuracy assessments on benchmarks. By configuring optimizer_llm_name and scorer_llm_dict appropriately and using robust API wrappers, the system achieves effective instruction evolution with controlled costs and improved reliability.

[No sources needed since this section summarizes without analyzing specific files]

## Appendices

### Best Practices for Optimizer-Scorer Pair Selection
- Use stronger scorers (e.g., GPT-4) for more accurate evaluations when cost allows.
- Use text-bison for cost-effective evaluations or when paired with strong optimizer diversity.
- Align meta-prompt formatting with the optimizer model family to maximize instruction quality.

[No sources needed since this section provides general guidance]