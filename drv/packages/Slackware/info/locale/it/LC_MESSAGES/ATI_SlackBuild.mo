��          �      �       H  C   I  )   �  	   �     �  �   �  �   �     �     �     �  �   �  $   U     z     �  A  �  B   �  )   "  	   L     V  %  n  �   �     j     |     �  �   �  #   H	     l	     �	                                          	   
                     If you want to use the new drivers, you will\n      must rerun it.  and you have the module fglrx in memory. --version Backup library:  NOTE: some library are been renamed to FGL.renamed.library_name.\n      To remove this package, you can use:\n\n\t\taticonfig --uninstall\n\n      or, with the releases >= 11.3, with:\n\n\t\tati-driver-installer-<release>-<architecture>.run --uninstall NOTE: you have to modify the X server configuration file to use the ATI drivers:\n\n\t\taticonfig --initial\n\n      can it help you. Run aticonfig without options for more details. Only root can do it! Removing pakage:  Restoring library:  \n      If you want to use the new drivers, you will must kill the X server,\n      so running:\n\n\t\tmodprobe -r fglrx\n\n      before restart it. \nNOTE: you are running the X server command not found. invalid option. Project-Id-Version: ATI_SlackBuild
Report-Msgid-Bugs-To: 
POT-Creation-Date: 2011-02-20 20:36+0100
PO-Revision-Date: 2011-02-20 20:39+0100
Last-Translator: Emanuele Tomasi <tomasi@cli.di.unipi.it>
Language-Team:
Language: it
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
  Se si vogliono usare i nuovi driver, lo si 
      deve riavviare.  e il modulo fglrx � caricato in memoria. --version Backup della libreria:  NOTA: alcune librerie sono state rinominate in FGL.renamed.nome_libreria.
      Per rimuovere questo pacchetto si pu� usare:

              aticonfig --uninstall

      oppure, con le versioni dei driver >= 11.3, con:

            ati-driver-installer-<versione>-<architettura>.run --uninstall NOTA: si deve modificare il file di configurazione del server X per poter usare
      i driver ATI:

            aticonfig --initial

      pu� essere di aiuto. Eseguire aticonfig senza opzioni per altri dettagli. Devi essere root! Rimozione del pacchetto:  Ripristino della libreria:  \n      Se si vogliono usare i nuovi driver, si deve fermare il server X e quindi
      dare:

        modprobe -r fglrx

      prima di rieseguirlo. \nNOTA: il server X � in esecuzione comando non trovato. opzione non valida. 