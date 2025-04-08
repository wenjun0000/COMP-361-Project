## Abstract
Understanding robotic pathfinding algorithms can be difficult due to their mathematical and abstract nature. This project addresses that challenge by developing an interactive educational game applet using the Godot Engine to visually teach and simulate four core algorithms: Visibility Graph, Trapezoid Decomposition, A*, and Dijkstra's Algorithm. The applet allows users to manually build graphs, interact with environments, and observe algorithm outputs through animations. This solution bridges the gap between theory and practice by making algorithm learning engaging and experiment driven.
  
## Introduction
Problem Definition:
University students often struggle to understand robotic pathfinding algorithms due to their abstract representation and mathematical complexity. Concepts like graph construction, space partitioning, and heuristic search are difficult to visualize, especially in static learning environments.
Challenges:
- High Cognitive Load: Algorithms like Trapezoidal Decomposition involve multiple geometric transformations, spatial relationships, and conditional logic. Without guided interaction, students are forced to mentally simulate these steps, leading to surface level understanding.
- Passive Learning Modalities: Conventional teaching relies on lectures, slides, or animations, which often fail to foster active engagement. Students observe rather than construct the algorithm, which limits their retention and ability to apply the knowledge in exams or real world settings.
- Lack of Feedback Driven Learning: Students rarely receive feedback on their intermediate understanding. This creates blind spots that go undetected until assessments, where even minor misunderstandings can lead to significant performance loss.
  
## Existing Approaches and Their Limitations:
- Algorithm Visualizers (e.g., VisuAlgo, Pathfinding Visualizer): These tools present algorithms step by step through animations. While useful for initial exposure, they do not allow students to manipulate the algorithm or receive feedback based on their own actions. The learning remains observational, not experiential.
- Online Courses and Video Tutorials: Though widely accessible, these resources are inherently passive. Students can replay content but not interact with the algorithm’s structure or logic.
- Coding Platforms (e.g., LeetCode, HackerRank): These environments are optimized for testing problem solving skills but are not designed to teach the conceptual stages of algorithms incrementally or visually.
  
## Proposed Solutions:
This project presents an interactive, gamified educational application built in Godot, specifically designed to teach the Trapezoidal Decomposition algorithm through step by step user engagement. The application directly addresses the pedagogical shortcomings of traditional and existing digital learning tools.
Key Contributions:
- Hands On Algorithm Construction:
Students perform each step of the algorithm manually, placing vertical lines, identifying regions, and selecting paths, turning abstract logic into concrete actions.
- Gamified Learning Experience:
Game mechanics such as scoring, feedback, and challenge modes are embedded into the learning process to encourage repetition and mastery without frustration.
- Step by Step Guided Flow with Optional Automation:
Each phase of the algorithm is broken into discrete, interactive stages. Students may proceed manually or use a "Finish" button to auto complete steps once the concept is understood.
-	Explorable Algorithm Behavior:
Students can experiment with different inputs and see how the algorithm responds dynamically, promoting curiosity and self driven exploration.
-	Bridge Between Theory and Practice:
By simulating geometric decomposition in an interactive environment, the tool connects formal algorithmic principles to intuitive spatial reasoning.
-	Accessibility and Reusability:
Built in Godot, the application is open source and platform independent, making it a reusable asset for future educators or self learners.

## Scope of the project:
We present an educational game applet built in the Godot Engine. It teaches four major robotic algorithms:
1.	Visibility Graph + Dijkstra: Shortest path in polygonal environments using graph construction and uniform cost search.
2.	Trapezoid Decomposition: Decomposes space into trapezoids and applies Dijkstra over region centers.
3.	A* Algorithm: Heuristic based search in a grid, allowing both manual and automatic movement.
4.	Dijkstra’s Algorithm: Applied within graphs to find shortest paths using uniform cost.
## Input/Output Interfacing
-	User Inputs: Mouse clicks for edge creation, tile selection, and UI toggles; keyboard for manual character control.
-	Expected Output: Visual path on screen, updated in real time as the algorithm proceeds. HUD displays active tile, steps, and parameters. As shown in Appendix, the user interface allows interactive visibility graph construction, with feedback such as edge counts and obstacle toggling in A* algorithm.
Interaction per Module:
-	Visibility Graph: Manual edge drawing, then automated graph completion and Dijkstra path.
-	Trapezoid: Auto sweep line decomposition, graph generation, and smoothed final path.
-	A* Grid: Manual or mouse click movement with red path animation.
## Summary and Conclusions
This project delivers an interactive, gamified application for teaching robotics path finding, designed to overcome the limitations of passive learning tools. By combining step by step manual execution, immediate feedback, and intuitive visual design, the application helps students internalize complex spatial logic through active engagement. While certain areas like advanced geometry handling and customization remain open for improvement, the core system demonstrates a compelling model for algorithm education through hands on interaction. 
Future Improvements:
-	Support for Additional Algorithms:
Extend the framework to include other path planning algorithms for comparative learning and broader applicability.
-	User Created Environments:
Implement features that allow students to draw their own polygonal maps, place custom start/goal points, and save or share scenarios.
-	Contextual Feedback System:
Enhance the error handling system to provide detailed explanations for incorrect actions, reinforcing conceptual understanding.
-	Adaptive Learning Mechanics:
Introduce difficulty scaling or guided hints based on student performance to support personalized learning trajectories.
-	Web Deployment and Broader Accessibility:
Export the application for web platforms to make it easily accessible without requiring local installation.
-	Extended Gamification Features:
Add timed challenges, level progression, achievement tracking, or leaderboards to further motivate repeated play and mastery.
## References
1.	Godot Engine Documentation – https://docs.godotengine.org
2.	Wikimedia Foundation. (2024). Pathfinding. Wikipedia. https://en.wikipedia.org/wiki/Pathfinding
3.	Course slides and assignments from Intro to Robotics, [University of the Fraser Valley].
4.	Coco Code. (2023). Start Your Game Creation Journey Today! (Godot beginner tutorial). YouTube. https://www.youtube.com/watch?v=5V9f3MT86M8&t=13s%29 
