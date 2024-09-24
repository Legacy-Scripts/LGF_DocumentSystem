import React, { useEffect, useState } from "react";
import styled, { keyframes } from "styled-components";
import {
  IconUser,
  IconCalendar,
  IconId,
  IconClock,
  IconPencil,
  IconGenderMale,
  IconGenderFemale,
} from "@tabler/icons-react";
import { PlayerData } from "../Types";
import { Flex, Text, Avatar } from "@mantine/core";
import { fetchNui } from "../utils/fetchNui";
import iconMap from "./Icon";

interface Document {
  type: string;
  title: string;
  icon: string;
  bgColor: string;
}

interface DocumentProps {
  visible: boolean;
  playerData: PlayerData | null;
}

const slideIn = keyframes`
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
`;

const slideOut = keyframes`
  from {
    transform: translateX(0);
    opacity: 1;
  }
  to {
    transform: translateX(100%);
    opacity: 0;
  }
`;

const Container = styled.div<{ visible: boolean; bgcolor: string }>`
  position: absolute;
  right: 2rem;
  max-width: 100%;
  width: 26rem;
  height: 11.7rem;
  background-color: ${({ bgcolor }) => bgcolor || "#1A1B1E"};
  background-image: radial-gradient(
    rgba(0, 248, 185, 0.55) 0%,
    rgba(0, 248, 185, 0.22) 100%
  );
  background-blend-mode: overlay;
  border: 1px solid #25262b;
  border-radius: 0.5rem;
  box-shadow: 0 10px 15px rgba(0, 0, 0, 0.2);
  padding: 0.8rem;
  color: white;
  margin-top: 2.5rem;
  animation: ${({ visible }) => (visible ? slideIn : slideOut)} 0.4s ease
    forwards;

  @media (max-width: 768px) {
    right: 1rem;
    width: 100%;
    margin-right: 0;
  }
`;

const Header = styled(Flex)`
  justify-content: space-between;
  align-items: center;
`;

const Title = styled.h1`
  font-size: 1rem;
  font-weight: bold;
  text-transform: uppercase;
  display: flex;
  align-items: center;
  margin-left: 8px;
`;

const SignatureContainer = styled(Flex)`
  justify-content: space-between;
  align-items: center;
  padding: 0 10px;
`;

const Signature = styled.p`
  font-size: 1.775rem;
  font-family: "Great Vibes", cursive;
  margin: 0;
  margin-bottom: 0.3rem;
  color: orange;
  margin-right: 0.5rem;
`;

const InfoRow = styled(Flex)`
  align-items: center;
  font-size: 0.875rem;
`;

const Document: React.FC<DocumentProps> = ({ visible, playerData }) => {
  const [availableDocs, setAvailableDocs] = useState<Document[]>([]);
  const [iconComponent, setIconComponent] = useState<React.ReactNode>(null);
  type IconName = keyof typeof iconMap;

  useEffect(() => {
    if (visible) {
      const fetchAvailableDocs = async () => {
        const docs = (await fetchNui(
          "LGF_DocumentSystem.GetDocumentAvailable"
        )) as Document[];
        setAvailableDocs(docs);
      };

      fetchAvailableDocs();
    }
  }, [visible]);

  const getDocumentConfig = () => {
    return (
      availableDocs.find((doc) => doc.type === playerData?.TypeDocs) || {
        title: "Unknown Document",
        icon: null,
        bgColor: "#1A1B1E",
      }
    );
  };

  useEffect(() => {
    const loadIcon = () => {
      if (availableDocs.length > 0) {
        const docConfig = getDocumentConfig();
        if (docConfig.icon && iconMap[docConfig.icon as IconName]) {
          const IconComponent = iconMap[docConfig.icon as IconName];
          setIconComponent(<IconComponent size={30} color="orange" />);
        } else {
          console.error(`Icon not found: ${docConfig.icon}`);
          setIconComponent(null);
        }
      }
    };

    loadIcon();
  }, [availableDocs]);

  if (!visible || !playerData) return null;

  const { title, bgColor } = getDocumentConfig();

  return (
    <Container visible={visible} bgcolor={bgColor}>
      <Header>
        <Title>
          <IconId size={26} style={{ marginRight: "8px" }} />
          {title}
        </Title>
        <div>{iconComponent}</div>
      </Header>
      <Flex direction="column" gap={3}>
        <Flex justify="flex-start" align="center" style={{ marginTop: "7px" }}>
          <Avatar
            size="xl"
            mb={10}
            src={playerData.Avatar}
            alt={`${playerData.Name} ${playerData.Surname}`}
          />
          <Flex direction="row" gap="md" style={{ marginLeft: "10px" }}>
            <Flex direction="column" gap="xs">
              <InfoRow>
                <IconUser size={16} style={{ marginRight: "5px" }} />
                <strong>NAME:</strong>
                <Text style={{ marginLeft: "5px" }}>{playerData.Name}</Text>
              </InfoRow>
              <InfoRow>
                <IconCalendar size={16} style={{ marginRight: "5px" }} />
                <strong>DOB:</strong>
                <Text style={{ marginLeft: "5px" }}>{playerData.Dob}</Text>
              </InfoRow>
              <InfoRow>
                <IconId size={16} style={{ marginRight: "5px" }} />
                <strong>ID:</strong>
                <Text style={{ marginLeft: "5px" }}>{playerData.IdCard}</Text>
              </InfoRow>
            </Flex>
            <Flex direction="column" gap="xs">
              <InfoRow>
                <IconUser size={16} style={{ marginRight: "5px" }} />
                <strong>SURNAME:</strong>
                <Text style={{ marginLeft: "5px" }}>{playerData.Surname}</Text>
              </InfoRow>
              <InfoRow>
                {playerData.Sex === "m" ? (
                  <IconGenderMale size={16} style={{ marginRight: "5px" }} />
                ) : (
                  <IconGenderFemale size={16} style={{ marginRight: "5px" }} />
                )}
                <strong>SEX:</strong>
                <Text style={{ marginLeft: "5px" }}>{playerData.Sex}</Text>
              </InfoRow>
              <InfoRow>
                <IconClock size={16} style={{ marginRight: "5px" }} />
                <strong>EXPIRY:</strong>
                <Text style={{ marginLeft: "5px" }}>
                  {playerData.Expiration}
                </Text>
              </InfoRow>
            </Flex>
          </Flex>
        </Flex>
        <SignatureContainer>
          <Flex align="left" gap="xs">
            {" "}
            <IconCalendar size={16} />
            <Text tt="uppercase" size="xs" color="dimmed">
              {playerData.Released}
            </Text>
          </Flex>
          <Flex align="center">
            <IconPencil size={27} color="orange" />
            <Signature>
              {playerData.Name} {playerData.Surname}
            </Signature>
          </Flex>
        </SignatureContainer>
      </Flex>
    </Container>
  );
};

export default Document;
