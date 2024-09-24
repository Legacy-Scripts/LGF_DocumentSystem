import React, { useEffect, useState } from 'react';
import { fetchNui } from '../utils/fetchNui';
import DocumentBody from './Document';
import { PlayerData } from '../Types';
import './index.scss';
import { isEnvBrowser } from '../utils/misc'; 

const App: React.FC = () => {
    const [componentVisible, setComponentVisible] = useState<boolean>(false);
    const [documentData, setDocumentData] = useState<PlayerData | null>(null);


    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            const data = event.data;
            if (data.action === 'openDocument') {
                setComponentVisible(data.visible);
                console.log("visibile nel event listener")
                setDocumentData(data.DocsData);
            }
        };

        window.addEventListener('message', handleMessage);

        return () => {
            window.removeEventListener('message', handleMessage);
        };
    }, []);

    useEffect(() => {
        const keyHandler = (e: KeyboardEvent) => {
          if (componentVisible && e.code === 'Escape') {
            if (!isEnvBrowser()) {
              if (componentVisible) {
                fetchNui('LGF_DocumentSystem.CloseUI', { ui_name: 'openDocument' });
              }
            } else {
                setComponentVisible(false);
            }
          }
        };
    
        window.addEventListener('keydown', keyHandler);
    
        return () => {
          window.removeEventListener('keydown', keyHandler);
        };
      }, [componentVisible]);
    
    return (
        <>
            <DocumentBody visible={componentVisible} playerData={documentData} />

        </>
    );
};

export default App;
