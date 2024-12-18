import React, { useEffect, useState } from "react";
import {
  Card,
  Text,
  Group,
  Badge,
  Grid,
  Container,
  ScrollArea,
} from "@mantine/core";
import { motion } from "framer-motion";
import { fetchNui } from "../../utils/fetchNui";


interface DeliveryItem {
  id: number;
  task: string;
  vehicle: string;
  date: string;
  distance: string;
  status: string;
  driver: string;
}

const MyRecentDeliveryStats: React.FC<{ visible: boolean }> = ({ visible }) => {
  const [deliveryData, setDeliveryData] = useState<DeliveryItem[]>([]);


  const fetchRecentDelivery = async () => {
    try {
      const DeliveryData = (await fetchNui("LGF_TruckSystem.getTasksListByZone")) as DeliveryItem[]; 
      console.log("Fetched Delivery Data:", JSON.stringify(deliveryData));
      setDeliveryData(DeliveryData); 
    } catch (error) {
      console.error("Failed to fetch delivery data:", error);
    }
  };


  useEffect(() => {
    if (visible) {
      fetchRecentDelivery();
    }
  }, [visible]);

  return (
    <Container w={900} mt={120}>
      <Grid justify="center" align="flex-start">
        <Grid.Col span={12}>
          <ScrollArea scrollbarSize={0} h={500}>
            <Grid gutter="md">
              {deliveryData.map((delivery, index) => (
                <Grid.Col span={4} key={delivery.id}>
                  <motion.div
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ duration: 0.3, delay: index * 0.1 }}
                  >
                    <Card
                      style={{
                        backgroundColor: "rgba(55, 65, 81, 0.4)",
                      }}
                      withBorder
                      p="md"
                      h={130}
                    >
                      <Group position="apart">
                        <Text weight={500}>{delivery.task}</Text>
                        <Badge
                          variant="dot"
                          color={
                            delivery.status === "Completed" ? "green" : "yellow"
                          }
                        >
                          {delivery.status}
                        </Badge>
                      </Group>
                      <Text size="sm" color="dimmed">
                        Vehicle: {delivery.vehicle}
                      </Text>
                      <Text size="sm" color="dimmed">
                        Date: {delivery.date}
                      </Text>
                      <Text size="sm" color="dimmed">
                        Driver: {delivery.driver}
                      </Text>
                    </Card>
                  </motion.div>
                </Grid.Col>
              ))}
            </Grid>
          </ScrollArea>
        </Grid.Col>
      </Grid>
    </Container>
  );
};

export default MyRecentDeliveryStats;
