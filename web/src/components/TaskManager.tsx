import React, { useState, useEffect } from "react";
import {
  Box,
  Card,
  Text,
  Group,
  Container,
  ScrollArea,
  Progress,
  Badge,
  Transition,
  ThemeIcon,
  Title,
  Divider,
} from "@mantine/core";
import { IconClipboardCheck, IconCheck } from "@tabler/icons-react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { fetchNui } from "../utils/fetchNui";

interface Task {
  id: number;
  Description: string;
  completed: boolean;
}

interface DeliveryTaskProps {
  visible: boolean;
  taskInfo: any;
}

const DeliveryTask: React.FC<DeliveryTaskProps> = ({ visible, taskInfo }) => {
  const [tasks, setTasks] = useState<Task[]>([]);

  const setTaskInitial = async () => {
    try {
      const taskData = (await fetchNui("LGF_TruckSystem.GetInformationTasks")) as Task[];
      const initializedTasks = taskData.map((task, index) => ({
        ...task,
        id: index + 1,
        completed: false,
      }));
      setTasks(initializedTasks);
    } catch (error) {
      console.error("Error fetching initial tasks:", error);
    }
  };

  useNuiEvent<boolean>("LGF_Truck.UpdateTask", (taskCompleted) => {
    if (taskCompleted) {
      setTasks((prevTasks) => {
        const nextTaskIndex = prevTasks.findIndex(task => !task.completed);
        if (nextTaskIndex === -1) return prevTasks;

        const updatedTasks = [...prevTasks];
        updatedTasks[nextTaskIndex] = {
          ...updatedTasks[nextTaskIndex],
          completed: true,
        };
        return updatedTasks;
      });
    }
  });

  useEffect(() => {
    if (visible) {
      setTaskInitial();
    } else {
      setTasks([]);
    }
  }, [visible]); 

  return (
    <Container style={{ position: "fixed", right: 20, top: 300, width: 430 }}>
      <Transition mounted={visible} transition="slide-left" duration={300} timingFunction="ease">
        {(styles) => (
          <ScrollArea h={600} scrollbarSize={0}>
            <Card
              shadow="sm"
              radius="md"
              style={{
                ...styles,
                backgroundColor: "rgba(55, 65, 81, 0.8)",
                border: "1px solid rgba(255, 255, 255, 0.1)",
              }}
            >
              <Group spacing={7} position="center">
                <ThemeIcon color="teal" size={40} radius="xl">
                  <IconClipboardCheck size={24} />
                </ThemeIcon>
                <Title tt="uppercase" order={2}>
                  Delivery Tasks
                </Title>
              </Group>
              <Divider color="white" my="xs" label="Task Information" labelPosition="center" />
              <Box mt="md">
                {tasks.map((task) => (
                  <Box key={task.id} mt="xs">
                    <Group position="apart">
                      <Text
                        style={{
                          color: task.completed ? "dimmed" : "white",
                          display: "flex",
                          alignItems: "center",
                        }}
                      >
                        {task.Description}
                        {task.completed && (
                          <IconCheck size={25} color="teal" style={{ marginLeft: 8 }} />
                        )}
                      </Text>
                      <Badge color={task.completed ? "teal" : "pink"} variant="dot" />
                    </Group>
                    <Progress
                      value={task.completed ? 100 : 0}
                      color={task.completed ? "teal" : "gray"}
                      style={{ marginTop: "10px" }}
                      size="xl"
                      radius="md"
                      w={355}
                      h={8}
                    />
                  </Box>
                ))}
              </Box>
            </Card>
          </ScrollArea>
        )}
      </Transition>
    </Container>
  );
};

export default DeliveryTask;
