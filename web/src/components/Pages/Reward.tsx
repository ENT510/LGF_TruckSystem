import React, { useEffect, useState } from "react";
import {
  Box,
  Card,
  Text,
  Progress,
  Grid,
  Container,
  Image,
  Badge,
  Group,
  Center,
  ActionIcon,
  Tooltip,
  ScrollArea,
  Button,
  Transition,
  Divider,
  Title,
  Checkbox,
  ThemeIcon,
} from "@mantine/core";
import { motion } from "framer-motion";
import { IconGift, IconX } from "@tabler/icons-react";
import { fetchNui } from "../../utils/fetchNui";

interface Reward {
  level: number;
  itemName: string;
  quantity: number;
  image: string;
  itemHash: string;
  props: "vehicle" | "item" | "weapon"; 
  redeemed: boolean;
}

interface ExperienceRewardProps {
  playerLevel: number;
  visible: boolean;
}

const ExperienceReward: React.FC<ExperienceRewardProps> = ({
  playerLevel,
  visible,
}) => {
  const [rewardsData, setRewardsData] = useState<Reward[]>([]);
  const [selectedVehicle, setSelectedVehicle] = useState<Reward | null>(null); 

  const handleRedeem = async (
    itemName: string,
    level: number,
    type: string,
    quantity: number,
    spawnLocation?: "here" | "garage"
  ) => {
    await fetchNui("LGF_TruckSystem.rewardRedeemed", {
      Level: level,
      RewardItem: itemName,
      Type: type,
      Quantity: quantity,
      SpawnLocation: spawnLocation,
    });

    setRewardsData((prevRewards) =>
      prevRewards.map((reward) =>
        reward.itemHash === itemName ? { ...reward, redeemed: true } : reward
      )
    );

    if (type === "vehicle") {
      setSelectedVehicle(null);
    }
  };

  const fetchRewardsList = async () => {
    try {
      const allRewards = (await fetchNui(
        "LGF_TruckSystem.getRewardItems"
      )) as Reward[];
      setRewardsData(allRewards);
    } catch (error) {
      console.error("Error fetching rewards: ", error);
    }
  };

  useEffect(() => {
    if (visible) {
      fetchRewardsList();
    } else {
      setRewardsData([]);
      setSelectedVehicle(null);
    }
  }, [visible]);

  const handleClose = () => {
    setSelectedVehicle(null);
  };

  return (
    <Container w="100%" maw={900} mt={110}>
      <ScrollArea scrollbarSize={0} h={550}>
        <Grid align="flex-start" gutter="sm">
          {rewardsData.map((reward, index) => {
            const isUnlocked = playerLevel >= reward.level;
            const progressValue =
              playerLevel < reward.level
                ? Math.min((playerLevel / reward.level) * 100, 100)
                : 100;

            return (
              <Grid.Col span={4} key={reward.level}>
                <motion.div
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ duration: 0.3, delay: index * 0.1 }}
                >
                  <Card
                    style={{
                      backgroundColor: "rgba(55, 65, 81, 0.4)",
                      marginBottom: "8px",
                    }}
                    shadow="sm"
                    padding="lg"
                    radius="md"
                    withBorder
                    aria-label={`Reward for level ${reward.level}: ${reward.itemName}`}
                  >
                    <Card.Section>
                      <Center>
                        <Image
                          mt={10}
                          src={reward.image}
                          alt={reward.itemHash}
                          height={100}
                          width={240}
                          fit="contain"
                        />
                      </Center>
                    </Card.Section>

                    <Group position="apart" mt="md" mb="xs">
                      <Text weight={500}>{reward.itemName}</Text>
                      <Badge color={isUnlocked ? "teal" : "pink"} variant="dot">
                        {isUnlocked ? "Unlocked" : "Locked"}
                      </Badge>
                    </Group>

                    <Text size="sm" color="dimmed">
                      Required Level: {reward.level}
                    </Text>
                    {reward.quantity && (
                      <Text size="sm" color="dimmed">
                        Quantity: {reward.quantity}
                      </Text>
                    )}

                    <Box
                      style={{
                        display: "flex",
                        alignItems: "center",
                        marginTop: "8px",
                      }}
                    >
                      <Progress
                        value={progressValue}
                        color="teal"
                        style={{ flex: 1 }}
                        size="lg"
                      />
                      <Text size="xs" ml="sm">
                        {isUnlocked
                          ? reward.redeemed
                            ? "Redeemed"
                            : "Unlocked"
                          : "Locked"}
                      </Text>
                      <Tooltip
                        withArrow
                        withinPortal
                        color="dark"
                        position="right"
                        label="Retrieve Reward"
                      >
                        <ActionIcon
                          onClick={() => {
                            if (isUnlocked && !reward.redeemed) {
                              if (reward.props === "vehicle") {
                                setSelectedVehicle(reward);
                              } else {
                                handleRedeem(
                                  reward.itemHash,
                                  reward.level,
                                  reward.props,
                                  reward.quantity
                                );
                              }
                            }
                          }}
                          color={
                            isUnlocked && !reward.redeemed ? "teal" : "gray"
                          }
                          variant="light"
                          disabled={!isUnlocked || reward.redeemed}
                          style={{ marginLeft: "10px" }}
                        >
                          <IconGift size={18} />
                        </ActionIcon>
                      </Tooltip>
                    </Box>
                  </Card>
                </motion.div>
              </Grid.Col>
            );
          })}
        </Grid>
      </ScrollArea>

      {selectedVehicle && (
        <Transition
          mounted={!!selectedVehicle}
          transition="slide-up"
          duration={300}
        >
          {(styles) => (
            <Card
              shadow="sm"
              radius="md"
              p="lg"
              style={{
                backgroundColor: "hsl(222.2 84% 4.9%)",
                border: "1px solid rgba(255, 255, 255, 0.1)",
                position: "fixed",
                bottom: "35%",
                left: "40%", 
                transform: "translateX(-50%)",
                width: "340px",
                height: "210px", 
                ...styles,
              }}
            >
              <Group position="apart">
                <Title order={3} style={{ color: "white" }}>
                  {selectedVehicle.itemName}
                </Title>
                <ActionIcon onClick={handleClose} color="gray" variant="light">
                  <IconX size={18} />
                </ActionIcon>
              </Group>
              <Divider color="gray" my="xs" />
              <Box mt="md">
                <Text color="white" size="sm">
                  You have the opportunity to redeem the{" "}
                  {selectedVehicle.itemName}. Where would you like to spawn your
                  vehicle?
                </Text>
              </Box>

              <Box
                mt="md"
                style={{ display: "flex", justifyContent: "space-around" }}
              >
                <Button
                  onClick={() =>
                    handleRedeem(
                      selectedVehicle.itemHash,
                      selectedVehicle.level,
                      selectedVehicle.props,
                      selectedVehicle.quantity,
                      "here"
                    )
                  }
                  color="teal"
                  style={{ flex: 1, marginRight: "5px" }}
                >
                  Spawn Here
                </Button>
                <Button
                  onClick={() =>
                    handleRedeem(
                      selectedVehicle.itemHash,
                      selectedVehicle.level,
                      selectedVehicle.props,
                      selectedVehicle.quantity,
                      "garage"
                    )
                  }
                  color="teal"
                  style={{ flex: 1, marginLeft: "5px" }} 
                >
                  Spawn in Garage
                </Button>
              </Box>
            </Card>
          )}
        </Transition>
      )}
    </Container>
  );
};

export default ExperienceReward;
