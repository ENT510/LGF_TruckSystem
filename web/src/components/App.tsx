import React, { useEffect, useState } from "react";
import { fetchNui } from "../utils/fetchNui";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { isEnvBrowser } from "../utils/misc";
import Logistic from "./Menu";
import { Button, Stack } from "@mantine/core";
import "./index.scss";
import TaskManager from "./TaskManager";
import Dialog from "./Dialog";

const App: React.FC = () => {
  const [LogisticVisible, setLogisticVisible] = useState(false);
  const [taskVisible, setTaskVisible] = useState(false);
  const [dialogVisible, setDialogVisible] = useState(false);
  const [devMode, setDevMode] = useState(false);
  const [tasks, setTasks] = useState({});
  const [playerData, setPlayerData] = useState({});
  const [taskInfo, setTaskInfo] = useState({});
  const [npcData, setNpcData] = useState<{
    npcName: string;   
    dialogue: string;    
    zoneName: string;     
  } | null>(null);

  useNuiEvent<any>("openLogistic", (data) => {
    setLogisticVisible(data.Visible);
    setTasks(data.Tasks);
    setPlayerData(data.PlayerData);
  });

  useNuiEvent<any>("openTaskLogistic", (data) => {
    setTaskVisible(data.Visible);
    setTaskInfo(data.Tasks);
  });

  useNuiEvent<any>("openDialog", (data) => {
    setDialogVisible(data.Visible);
    setNpcData(data.npcData); 
  });

  useEffect(() => {
    const keyHandler = (e: KeyboardEvent) => {
      if (e.code === "Escape") {
        if (LogisticVisible) {
          if (!isEnvBrowser()) {
            fetchNui("LGF_TruckSystem:CloseUiByIndex", {
              name: "openLogistic",
            });
          }
          setLogisticVisible(false);
        }
      }
    };

    window.addEventListener("keydown", keyHandler);

    return () => {
      window.removeEventListener("keydown", keyHandler);
    };
  }, [LogisticVisible, taskVisible, dialogVisible]);

  return (
    <>
      <Logistic
        visible={LogisticVisible}
        tasks={tasks}
        playerData={playerData}
      />
      <TaskManager visible={taskVisible} taskInfo={taskInfo} />

      <Dialog
        visible={dialogVisible}
        npcData={npcData} 
      />

      {isEnvBrowser() && (
        <Button
          onClick={() => setDevMode((prev) => !prev)}
          variant="default"
          color="blue"
          style={{
            backgroundColor: "rgba(55, 65, 81, 0.4)",
            position: "fixed",
            top: 10,
            left: 10,
            zIndex: 1000,
            width: 150,
          }}
          aria-label={devMode ? "Disable Dev Mode" : "Enable Dev Mode"}
        >
          {devMode ? "Disable Dev Mode" : "Enable Dev Mode"}
        </Button>
      )}

      {devMode && (
        <Stack
          spacing="xs"
          style={{
            position: "fixed",
            top: 50,
            left: 10,
            zIndex: 1000,
            width: 150,
          }}
        >
          <Button
            style={{
              backgroundColor: "rgba(55, 65, 81, 0.4)",
            }}
            color="orange"
            onClick={() => setLogisticVisible(true)}
            variant="default"
          >
            Open Laptop
          </Button>
          <Button
            style={{
              backgroundColor: "rgba(55, 65, 81, 0.4)",
            }}
            color="orange"
            onClick={() => setTaskVisible(true)}
            variant="default"
          >
            Open Task
          </Button>
          <Button
            style={{
              backgroundColor: "rgba(55, 65, 81, 0.4)",
            }}
            color="orange"
            onClick={() => setDialogVisible(true)}
            variant="default"
          >
            Open Dialog
          </Button>
        </Stack>
      )}
    </>
  );
};

export default App;
