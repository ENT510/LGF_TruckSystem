import React, { useState, useEffect } from "react";
import { fetchNui } from "../utils/fetchNui";
import Lang from "../utils/LangR";
import {
  Box,
  NavLink,
  Avatar,
  Group,
  Text,
  Grid,
  Col,
  UnstyledButton,
  createStyles,
  CloseButton,
  RingProgress,
  Divider,
  Title,
} from "@mantine/core";
import { IconPackage, IconClock, IconStar } from "@tabler/icons-react";
import Dashboard from "./Pages/Dashboard";
import Delivery from "./Pages/Delivery";
import ExperienceReward from "./Pages/Reward";
import { useNuiEvent } from "../hooks/useNuiEvent";

const useStyles = createStyles((theme) => ({
  navLink: {
    display: "flex",
    alignItems: "center",
    padding: theme.spacing.xs,
    transition: "background-color 0.3s ease",
    borderRadius: "5px",
    marginTop: "5px",
    "&:hover": {
      backgroundColor: "hsl(220.9 39.3% 11%)",
    },
  },
  active: {
    color: theme.white,
  },
  icon: {
    transition: "transform 0.2s ease",
  },
  container: {
    display: "flex",
    height: "86vh",
  },
  menu: {
    width: "250px",
    padding: "md",
  },
  content: {
    flex: 1,
  },
}));

const getInitials = (name:string) => {
  return name
    .split(" ")        
    .map((word) => word[0]) 
    .join("")            
    .toUpperCase();         
};

const Menu: React.FC<{ visible: boolean; tasks: any; playerData?: any }> = ({
  visible,
  tasks,
  playerData = { PlayerName: "Unknown", CurrentLevel: 0, Avatar: "" },
}) => {
  const { classes, cx } = useStyles();
  const [activeParentIndex, setActiveParentIndex] = useState<number>(0);
  const [currentPage, setCurrentPage] = useState<React.ReactNode>(
    <Dashboard visible={visible} tasks={tasks} />
  );
  const [theme, setTheme] = useState<"light" | "dark">("dark");
  const lang = Lang();

  const getRankFromLevel = (level: number) => {
    if (level < 0) return 0;
    return Math.min(Math.floor(level / 10), 9);
  };

  const handleCloseUi = async () => {
    await fetchNui("LGF_TruckSystem:CloseUiByIndex", {
      name: "openLogistic",
    });
    setTimeout(() => {
      setActiveParentIndex(0);
      setCurrentPage(<Dashboard visible={visible} tasks={tasks} />);
    }, 2000);
  };

  useNuiEvent<any>("updateParent", () => {
    setTimeout(() => {
      setActiveParentIndex(0);
      setCurrentPage(<Dashboard visible={visible} tasks={tasks} />);
    }, 2000);
  });




  const playerRank = getRankFromLevel(playerData?.CurrentLevel || 0);

  const navItems = [
    {
      label: "Start Delivery",
      icon: <IconPackage className={classes.icon} size="1.5rem" stroke={1.5} />,
      description: "Overview Delivery available ",
      component: <Dashboard visible={visible} tasks={tasks} />,
    },
    {
      label: "Recent Deliveries",
      icon: <IconClock className={classes.icon} size="1.5rem" stroke={1.5} />,
      description: "Check Recent Deliveries",
      component: <Delivery visible={visible} />,
    },
    {
      label: "Experience Rewards",
      icon: <IconStar className={classes.icon} size="1.5rem" stroke={1.5} />,
      description: "View your rewards based on your level",
      component: <ExperienceReward playerLevel={playerData?.CurrentLevel || 0} visible={visible} />,
    },
  ];

  const navLinks = navItems.map((item, index) => (
    <NavLink
      key={item.label}
      label={item.label}
      description={item.description}
      icon={item.icon}
      className={cx(classes.navLink, {
        [classes.active]: index === activeParentIndex,
      })}
      active={index === activeParentIndex}
      onClick={() => {
        setActiveParentIndex(index);
        setCurrentPage(item.component);
      }}
      variant="filled"
      style={{
        backgroundColor:
          index === activeParentIndex ? "hsl(178.6 84.3% 10%)" : "transparent",
      }}
      childrenOffset={28}
      ml={5}
    />
  ));

  useEffect(() => {
    if (visible) {
      setCurrentPage(<Dashboard visible={visible} tasks={tasks} />);
    }
  }, [visible, tasks]);

  return (
    <div className={`truck-panel ${visible ? "slide-in" : "slide-out"}`}>
      <div
        className={classes.container}
        style={{
          backgroundColor:
            theme === "dark" ? "hsl(222.2 84% 4.9%)" : "hsl(217.2 32.6% 17.5%)",
        }}
      >
        <Box className={classes.menu}>
          <div
            style={{
              position: "absolute",
              top: "7%",
              left: "53%",
              transform: "translate(-50%, -50%)",
              zIndex: 5,
              textShadow: "2px 2px 4px rgba(0, 0, 0, 0.7)",
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
            }}
          >
            <Title mt={20} align="center" size="h1" tt="uppercase">
              Logistic Truck System
            </Title>

            <Text
              size={15}
              color="dimmed"
              align="center"
              style={{
                marginBottom: "10px",
              }}
            >
              Manage logistics with ease and precision
            </Text>
          </div>

          <Grid align="center" mb="md">
            <Col span={6}>
              <UnstyledButton style={{ pointerEvents: "none", width: "330px" }}>
                <Group>
                  <Avatar
                    mt={10}
                    ml={8}
                    src={playerData?.Avatar || ""}
                    size={55}
                    color="blue"
                  />
                  <div>
                  <Text size={20}>{getInitials(playerData?.PlayerName || "U")}</Text>
                    <Text tt="uppercase" color="dimmed" size={12}>
                      Rank: {playerRank}
                    </Text>
                  </div>
                </Group>
              </UnstyledButton>
            </Col>

            <Col span={1}>
              <Divider ml={30} mr={30} h={45} orientation="vertical" />
            </Col>

            <Col span={5}>
              <RingProgress
                size={55}
                thickness={2}
                ml={20}
               
                label={
                  <Text size="xs" align="center">
                    LV {playerData?.CurrentLevel ?? 0}
                  </Text>
                }
                sections={[{ value: playerData?.CurrentLevel || 0, color: "teal" }]}
              />
            </Col>

            

            <Col
              style={{
                position: "absolute",
                right: "10px",
                top: "10px",
                textAlign: "right",
              }}
            >
              <CloseButton
                color="red"
                variant="light"
                title="Close Diocane"
                size="lg"
                iconSize={20}
                onClick={handleCloseUi}
              />
            </Col>
          </Grid>

          <Box>{navLinks}</Box>
        </Box>
        <Divider ml={25} h={505} mt={40} orientation="vertical" />
        <Box className={classes.content}>{currentPage}</Box>
      </div>
    </div>
  );
};

export default Menu;
