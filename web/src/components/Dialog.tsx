import React from "react";
import {
  Box,
  Card,
  Text,
  Group,
  Transition,
  ThemeIcon,
  Title,
  Divider,
  Button,
  Badge,
} from "@mantine/core";
import { IconMessageCircle, IconTruckDelivery } from "@tabler/icons-react";
import { fetchNui } from "../utils/fetchNui";

interface NPCData {
  npcName: string;
  dialogue: string;
  zoneName: string;
}

interface NPCDialogProps {
  visible: boolean;
  npcData: NPCData | null; 
}

const NPCDialog: React.FC<NPCDialogProps> = ({ visible, npcData }) => {
  const handleConfirm = () => {
    fetchNui("LGF_TruckSystem.ConfirmDialogDelivery", { state: true });
  };

  return (
    <Transition
      mounted={visible}
      transition="slide-up"
      duration={300}
      timingFunction="ease"
    >
      {(styles) => (
        <div style={{ position: "fixed", left: 750, bottom: 20, width: 400, ...styles }}>
          <Card
            shadow="sm"
            radius="md"
            p="lg"
            style={{
              backgroundColor: "rgba(55, 65, 81, 0.8)",
              border: "1px solid rgba(255, 255, 255, 0.1)",
              height: 'auto', 
            }}
          >
            {npcData ? (
              <>
                <Group spacing={7} position="apart">
                  <Group spacing={7}>
                    <ThemeIcon color="teal" size={40} radius="md">
                      <IconMessageCircle size={24} />
                    </ThemeIcon>
                    <Title order={3} style={{ color: "white" }}>{npcData.npcName}</Title>
                  </Group>
                  <Badge color="teal" variant="dot">
                    {npcData.zoneName}
                  </Badge>
                </Group>
                <Divider color="gray" my="xs" label="Delivery Information" labelPosition="center" />
                <Box mt="md">
                  <Text color="white" size="sm">
                    {npcData.dialogue}
                  </Text>
                </Box>
                <Box mt="md" style={{ textAlign: "center" }}>
                  <Button
                    leftIcon={<IconTruckDelivery size={15} stroke={1} />}
                    variant="light"
                    color="teal"
                    onClick={handleConfirm}
                  >
                    Confirm Delivery Zone
                  </Button>
                </Box>
              </>
            ) : (
              <Text color="white" size="sm" style={{ textAlign: "center" }}>
                Loading...
              </Text> 
            )}
          </Card>
        </div>
      )}
    </Transition>
  );
};

export default NPCDialog;
