# Examples and Use Cases

<cite>
**Referenced Files in This Document**   
- [optimize_linear_regression.py](file://opro/optimization/optimize_linear_regression.py)
- [optimize_tsp.py](file://opro/optimization/optimize_tsp.py)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py)
- [opt_utils.py](file://opro/optimization/opt_utils.py)
- [prompt_utils.py](file://opro/prompt_utils.py)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py)
- [BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt)
- [BBH-logical_deduction_seven_objects-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-logical_deduction_seven_objects-s-text-bison-o-palm-2-l-it.txt)
- [README.md](file://README.md)
</cite>

## Table of Contents
1. [Linear Regression Optimization](#linear-regression-optimization)
2. [Traveling Salesman Problem Optimization](#traveling-salesman-problem-optimization)
3. [Prompt Optimization Workflow](#prompt-optimization-workflow)
4. [Historical Prompt Trajectories](#historical-prompt-trajectories)
5. [Meta-Prompt Templates and Instruction Evolution](#meta-prompt-templates-and-instruction-evolution)
6. [Adapting the System for New Domains](#adapting-the-system-for-new-domains)
7. [Applications Beyond Mathematical Problems](#applications-beyond-mathematical-problems)
8. [Lessons from Published Results](#lessons-from-published-results)

## Linear Regression Optimization

The opro system demonstrates its optimization capabilities through the linear regression example, which serves as a foundational case for understanding how the framework optimizes mathematical problem-solving strategies. This example involves minimizing the objective function of a linear regression problem by iteratively refining parameter estimates (w, b) to reduce the loss function, which is defined as the squared norm of residuals between predicted and actual values.

The optimization process begins with generating synthetic data points based on a linear relationship with added noise, establishing ground truth parameters (w_true, b_true). The system initializes multiple starting points for the parameters and evaluates their corresponding loss values. Using a large language model (LLM) as an optimizer—such as text-bison or GPT variants—the system generates new (w, b) pairs through a meta-prompting mechanism that incorporates historical input-output pairs and their associated loss values.

The meta-prompt guides the LLM to propose new parameter combinations that yield lower loss values than previously observed. These proposals are parsed from the LLM's output, evaluated for their actual loss, and added to the set of known solutions. This iterative loop continues until either the optimal parameters are found or a maximum number of steps is reached. The process leverages the LLM’s ability to explore the solution space intelligently, avoiding random search and instead focusing on promising regions informed by past evaluations.

This approach highlights how opro transforms traditional numerical optimization into a language-guided search, where the LLM acts as a cognitive optimizer that reasons about mathematical relationships and suggests improvements based on empirical feedback.

**Section sources**
- [optimize_linear_regression.py](file://opro/optimization/optimize_linear_regression.py#L1-L424)

## Traveling Salesman Problem Optimization

The traveling salesman problem (TSP) represents a classic combinatorial optimization challenge, where the goal is to find the shortest possible route that visits each city exactly once and returns to the origin city. In opro, this problem is addressed by optimizing over permutations of city indices to minimize the total travel distance, demonstrating the system's capability in handling discrete, high-dimensional search spaces.

The TSP optimization workflow begins by generating a set of random 2D coordinates for cities. An initial solution is constructed using heuristic algorithms such as nearest neighbor or farthest insertion, providing a baseline tour length. The system then employs an LLM-based optimizer to refine this solution by proposing new city visitation sequences (traces) that result in shorter total distances.

A meta-prompt is crafted to present the LLM with a list of previous traces and their corresponding lengths, sorted in descending order of performance (shorter lengths are better). The LLM is instructed to generate a new trace that differs from all previously seen ones and achieves a shorter length. The output is parsed to extract the proposed city sequence, which is then validated for correctness (visiting all cities exactly once) and evaluated for its total distance.

This iterative refinement process allows the system to progressively improve the solution quality, leveraging the LLM’s capacity for pattern recognition and combinatorial reasoning. The TSP example underscores opro’s significance in solving complex optimization problems beyond continuous parameter spaces, showcasing its versatility in tackling NP-hard challenges through guided language-based search.

**Section sources**
- [optimize_tsp.py](file://opro/optimization/optimize_tsp.py#L1-L430)

## Prompt Optimization Workflow

The core functionality of opro lies in its ability to optimize prompts used to guide large language models in performing tasks. This is achieved through a structured workflow implemented in `optimize_instructions.py`, which systematically evolves instructions to maximize performance on a given dataset and task.

The workflow begins with defining initial instructions, such as "Let's solve the problem." These instructions are evaluated on a training subset of the target dataset using a scorer LLM (e.g., text-bison or GPT-3.5-turbo), which computes accuracy metrics for each instruction. The results inform a meta-prompt that presents the optimizer LLM with a history of previous instructions and their scores, encouraging it to generate new instructions that outperform past ones.

Key configuration parameters include:
- **Optimizer and Scorer Models**: Specifies which LLMs are used for generating new instructions and evaluating their effectiveness.
- **Instruction Position**: Determines where the instruction is inserted relative to the input (e.g., at the beginning of the question or answer).
- **Few-Shot Examples**: Optional exemplars included in the meta-prompt to provide context for instruction refinement.
- **Search Steps**: The number of iterations over which instruction evolution occurs.

At each step, the optimizer generates multiple candidate instructions, which are evaluated and retained if they meet a minimum performance threshold. High-performing instructions are incorporated into subsequent meta-prompts, creating a feedback loop that drives continuous improvement. This evolutionary process mimics natural selection, where only the fittest (most effective) instructions survive and propagate.

The workflow culminates in a set of optimized instructions that significantly outperform the initial baselines, demonstrating the system’s capacity for autonomous prompt engineering.

**Section sources**
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L1-L804)
- [opt_utils.py](file://opro/optimization/opt_utils.py#L1-L1036)

## Historical Prompt Trajectories

Analysis of historical prompt results, particularly those stored in the `misc/prompt_history/` directory, provides valuable insights into the evolution of instruction effectiveness over time. These logs capture the progression of instruction candidates across optimization steps, including their training accuracy and textual content.

For instance, in the file `BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt`, we observe a trajectory where initial instructions range from simple logical expressions to more elaborate explanations. Over successive steps, the system discards low-performing variants (e.g., those achieving only 40–60% accuracy) while retaining and building upon higher-performing ones (e.g., reaching 90–96% accuracy). Notably, the winning instructions often adopt concise, rule-based formulations such as "False and not (True and not not False) and (not False) is False," which effectively guide the model toward correct evaluations.

Similarly, in `BBH-logical_deduction_seven_objects-s-text-bison-o-palm-2-l-it.txt`, the instruction evolution focuses on clarifying the task structure and logical consistency requirements. Early attempts emphasize general reasoning strategies, while later iterations refine the phrasing to explicitly direct attention to object ordering and relational constraints, resulting in incremental accuracy gains.

These trajectories illustrate how opro navigates the space of possible instructions, balancing exploration (trying novel formulations) with exploitation (refining successful patterns). By analyzing these logs, users can identify common characteristics of high-performing instructions, such as clarity, specificity, and alignment with the underlying task logic.

**Section sources**
- [BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-boolean_expressions-s-text-bison-o-palm-2-l-it.txt#L1-L800)
- [BBH-logical_deduction_seven_objects-s-text-bison-o-palm-2-l-it.txt](file://misc/prompt_history/BBH-logical_deduction_seven_objects-s-text-bison-o-palm-2-l-it.txt#L1-L361)

## Meta-Prompt Templates and Instruction Evolution

Meta-prompt templates are central to opro’s instruction optimization mechanism, serving as the interface through which historical performance data guides the generation of improved instructions. These templates are dynamically constructed based on the current state of the optimization process, incorporating previous instruction-score pairs and optionally including few-shot examples from the dataset.

The structure of a meta-prompt varies depending on the optimizer model and task type. For fine-tuned models like text-bison, the template may present instruction-score pairs in ascending order of quality, emphasizing that higher scores indicate better performance. For pre-trained models like GPT-3.5-turbo, the template might frame the task as generating a new instruction that surpasses all previous ones in effectiveness.

An example meta-prompt structure includes:
- A description of the task and instruction position.
- A list of previous instructions and their scores, formatted for clarity.
- Few-shot QA pairs (if enabled), showing how instructions are applied to specific inputs.
- A directive to generate a new instruction that improves upon the best-performing ones.

As optimization proceeds, the meta-prompt evolves, incorporating newly discovered high-scoring instructions and discarding outdated or underperforming ones. This dynamic updating ensures that the search remains focused on the most promising regions of the instruction space.

The evolution of instructions reflects a shift from generic directives ("Let's think step by step") to highly specialized formulations tailored to the nuances of the target task. This transformation is driven by the feedback loop between evaluation and generation, enabling the system to converge on optimal prompting strategies.

**Section sources**
- [opt_utils.py](file://opro/optimization/opt_utils.py#L1-L1036)
- [prompt_utils.py](file://opro/prompt_utils.py#L1-L133)

## Adapting the System for New Domains

The opro framework is designed to be adaptable to new domains beyond mathematical reasoning and combinatorial optimization. By modifying meta-prompt templates and adjusting configuration parameters, users can apply the system to diverse tasks such as code generation, creative writing, and domain-specific problem solving.

To adapt opro for a new domain:
1. **Define the Task and Dataset**: Identify the target dataset and task format (e.g., code completion, story generation).
2. **Customize Instruction Position**: Determine where the instruction should be inserted in the input (e.g., before a code snippet or narrative prompt).
3. **Adjust Evaluation Metrics**: Modify the scoring function to align with domain-specific success criteria (e.g., code correctness, narrative coherence).
4. **Curate Few-Shot Examples**: Select representative exemplars that illustrate desired behaviors and include them in the meta-prompt.
5. **Tune Hyperparameters**: Set appropriate values for search steps, temperature, and batch size to balance exploration and efficiency.

For example, in code generation, the meta-prompt could instruct the optimizer to generate comments or function headers that improve code readability and functionality. In creative writing, it might focus on stylistic elements such as tone, pacing, or character development.

This flexibility enables opro to serve as a general-purpose optimization tool for any application where language-guided improvement can enhance performance.

**Section sources**
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L1-L804)
- [README.md](file://README.md#L1-L79)

## Applications Beyond Mathematical Problems

While opro excels in mathematical and logical domains, its applications extend to a wide range of non-mathematical tasks. The system’s ability to optimize prompts makes it suitable for enhancing performance in areas such as natural language understanding, code synthesis, and content creation.

In **code generation**, opro can evolve instructions that guide LLMs to produce more efficient, readable, or secure code. For instance, starting with a basic prompt like "Write a Python function," the system can iteratively refine it to include constraints such as "Use list comprehensions for efficiency" or "Include error handling for edge cases."

In **creative writing**, opro can optimize prompts to generate stories with specific themes, tones, or structures. Initial instructions like "Write a short story" can evolve into detailed directives such as "Write a mystery story set in 1920s Paris, featuring a detective who solves crimes using logic and deduction."

In **question answering and reasoning tasks**, opro improves the quality of responses by refining prompts to encourage step-by-step thinking, fact verification, or multi-hop inference. This is particularly valuable in domains like medical diagnosis or legal analysis, where precision and reliability are critical.

These applications demonstrate that opro’s core principle—using LLMs to optimize other LLMs via meta-prompts—is broadly applicable across domains, enabling automated improvement of AI-driven workflows.

**Section sources**
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L1-L804)
- [evaluate_instructions.py](file://opro/evaluation/evaluate_instructions.py#L1-L770)

## Lessons from Published Results

The published results associated with opro, as detailed in the accompanying research paper, offer several key insights into the effectiveness and limitations of using large language models as optimizers. One major finding is that LLM-based optimization can consistently outperform manual prompt engineering, achieving significant gains in task accuracy across diverse benchmarks such as MMLU, BIG-Bench Hard (BBH), and GSM8K.

A critical lesson is the importance of **feedback quality** in the optimization loop. The scorer LLM must provide reliable and consistent evaluations of instruction performance; otherwise, the optimizer may converge on suboptimal or misleading solutions. This underscores the need for careful selection of scorer models and validation of evaluation metrics.

Another insight is the **sensitivity to hyperparameters**, such as temperature, number of search steps, and few-shot example selection. Small changes in these settings can lead to vastly different optimization trajectories, highlighting the need for systematic experimentation and tuning.

Additionally, the results reveal that **instruction diversity** plays a crucial role in avoiding premature convergence. By maintaining a diverse pool of candidate instructions and periodically introducing randomness, the system can escape local optima and discover globally superior solutions.

Finally, the study emphasizes the **cost-benefit trade-off** of API-based optimization. While powerful, repeated calls to commercial LLM APIs can incur substantial costs, making self-hosted or open-source models attractive alternatives for large-scale experimentation.

These lessons collectively inform best practices for deploying opro in real-world scenarios, ensuring robust, efficient, and scalable optimization outcomes.

**Section sources**
- [README.md](file://README.md#L1-L79)
- [optimize_instructions.py](file://opro/optimization/optimize_instructions.py#L1-L804)