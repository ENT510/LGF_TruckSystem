import React from "react";
import {
  Container,
  Card,
  Text,
  Grid,
  Col,
  Group,
  ThemeIcon,
  ScrollArea,
  Badge,
  Tooltip,
  ActionIcon,
  Title,
  Image,
} from "@mantine/core";
import {
  IconPlayerPlay,
  IconStar,
  IconMapPin,
  IconCoins,
  IconTrendingUp,
} from "@tabler/icons-react";
import { motion } from "framer-motion";
import { fetchNui } from "../../utils/fetchNui";

const TruckDashboard: React.FC<{ visible: boolean; tasks: any }> = ({
  visible,
  tasks,
}) => {
  const handleStartTask = async (zoneName: string, coords: string, IndexTask:number,unloadCoords:string, distance:number, pricexkm: number,requiredLevel:number,lvincrease:number) => {
    fetchNui("LGF_TruckSystem.startTask", {
      zoneName: zoneName,
      coords: coords,
      indexTask: IndexTask,
      unloadCoords:unloadCoords,
      distance:distance,
      pricexkm:pricexkm,
      lvincrease:lvincrease,
      requiredLevel:requiredLevel
    });
  };

  return (
    <Container>
      <Grid>
        <Col span={12}>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.5 }}
          >
            <Card
              style={{ width: "920px", backgroundColor: "transparent" }}
              radius="lg"
              shadow="sm"
              h={650}
            >
              <Grid mt={100}>
                <Col span={12}>
                  <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 0.5 }}
                  >
                    <ScrollArea scrollbarSize={0} h={510}>
                      <Grid gutter="md">
                        {tasks && tasks.length > 0 ? (
                          tasks.map((task: any, index: number) => (
                            <Col span={4} key={task.id}>
                              <motion.div
                                initial={{ opacity: 0, scale: 0.8 }}
                                animate={{ opacity: 1, scale: 1 }}
                                transition={{
                                  duration: 0.3,
                                  delay: index * 0.1,
                                }}
                              >
                                <Card
                                  withBorder
                                  h={280}
                                  style={{
                                    backgroundColor: "rgba(55, 65, 81, 0.4)",
                                    padding: "15px",
                                  }}
                                  radius="md"
                                >
                                  <Image
                                    src={task.img}
                                    alt={task.vehicle}
                                    height={80}
                                    fit="contain"
                                  />

                                  <Group position="apart" mt="xs">
                                    <Text
                                      size="sm"
                                      tt="uppercase"
                                      mb={10}
                                      weight={500}
                                    >
                                      {task.task}
                                    </Text>
                                    <Badge
                                      radius="sm"
                                      color="teal"
                                      variant="dot"
                                      size="md"
                                    >
                                      {task.vehicle}
                                    </Badge>
                                  </Group>

                                  <Group mt="md" spacing="xs">
                                    <ThemeIcon color="cyan" variant="light">
                                      <IconTrendingUp size={18} />
                                    </ThemeIcon>
                                    <Text size="sm">
                                      Required Level: {task.requiredLvl}
                                    </Text>
                                  </Group>

                                  <Group spacing="xs" mt="xs">
                                    <ThemeIcon color="yellow" variant="light">
                                      <IconCoins size={18} />
                                    </ThemeIcon>
                                    <Text size="sm">
                                      Price x Km: {task.price}
                                    </Text>
                                  </Group>

                                  <Group spacing="xs" mt="xs">
                                    <ThemeIcon color="green" variant="light">
                                      <IconStar size={18} />
                                    </ThemeIcon>
                                    <Text size="sm">
                                      Lv Reward: {task.lvincrease}
                                    </Text>
                                  </Group>
{/* 
                                  <Group spacing="xs" mt="xs">
                                    <ThemeIcon color="blue" variant="light">
                                      <IconMapPin size={18} />
                                    </ThemeIcon>
                                    <Text size="sm">
                                      Distance Delivery: {task.distance}
                                    </Text>
                                  </Group> */}

                                  <Group
                                    style={{
                                      position: "absolute",
                                      right: "10px",
                                      bottom: "10px",
                                    }}
                                    position="right"
                                    spacing="xs"
                                  >
                                    <Tooltip
                                      color="dark"
                                      label={`Start Delivery ${task.task}`}
                                      withArrow
                                    >
                                      <ActionIcon
                                        color="teal"
                                        variant="outline"
                                        size={30}
                                        onClick={() =>
                                          handleStartTask(task.zoneName, task.coordsDelivery, task.id, task.unloadCoords, task.distance, task.price,task.requiredLvl,task.lvincrease)
                                        }
                                      >
                                        <IconPlayerPlay size={20} />
                                      </ActionIcon>
                                    </Tooltip>
                                  </Group>
                                </Card>
                              </motion.div>
                            </Col>
                          ))
                        ) : (
                          <Text>No tasks available</Text>
                        )}
                      </Grid>
                    </ScrollArea>
                  </motion.div>
                </Col>
              </Grid>
            </Card>
          </motion.div>
        </Col>
      </Grid>
    </Container>
  );
};

export default TruckDashboard;
