#include <cstdio>
#include <iomanip>
#include <iostream>
#include <string>

#include "libpq-fe.h"

#define HOST "127.0.0.1"
#define USER "inserire il nome utente"
#define DB "inserire il nome del database"
#define PASSWORD "inserire la propria password"
#define PORT 5432

using namespace std;

bool controlloRisultato(PGresult* res, const PGconn* conn);
void stampaIntestazione(int dim, PGresult* result, int colonne);
void stampaContenuto(int dim, PGresult* result, int colonne, int righe);
void stampaChisura(int dim, int colonne);

int main() {
  cout << "Inizio del progamma!" << endl;

  char connInfo[100];

  sprintf(connInfo, "user=%s password=%s dbname=%s hostaddr=%s port=%d", USER, PASSWORD, DB, HOST, PORT);

  PGconn* conn = PQconnectdb(connInfo);

  if (PQstatus(conn) != CONNECTION_OK) {
    cout << "C'è stato un errore durante la connessione! Errore: " << PQerrorMessage(conn) << endl;
    PQfinish(conn);
    exit(1);
  } else {
    cout << "Connessione stabilita con successo!" << endl;
  }

  char continua;

  cout << "1. Elenco ordinato degli istruttori che hanno raccolto il maggior numero di partecipazioni ai loro corsi." << endl;

  cout << endl;

  cout << "2. Elenco ordinato degli enti che hanno registrato il maggior numero di infortuni in allenamento per una determinata fascia di ranking." << endl;

  cout << endl;

  cout << "3. Per ogni pilota determinare la pista che ha frequentato di maggiormente (in termini di eventi, corsi e allenamenti)." << endl;
  cout << "   Se un pilota ha frequentato maggiormente più piste (stesso numero di presenze), mostrare tutte le tuple." << endl;

  cout << endl;

  cout << "4. Elenco dei piloti (e corrispettiva data) che hanno subito un infortunio lo stesso giorno in cui hanno fatto il loro giro più veloce in una pista." << endl;

  cout << endl;

  cout << "5. Per ogni circuito, restituire il miglior tempo assoluto, indicando anche il pilota che detiene il record." << endl;

  cout << endl;

  cout << "6. Trovare i membri del personale che sono anche piloti e che hanno eseguito un'operazione di manutenzione e un allenamento durante la stessa giornata." << endl;

  cout << endl;

  do {
    cout << "Inserisci il numero di query che vuoi eseguire!" << endl;
    int scelta;

    cin.clear();

    cin >> scelta;

    if (!(cin.fail()) && scelta >= 1 && scelta <= 6) {
      string query;
      PGresult* result;

      switch (scelta) {
        case 1:
          cout << "Elenco ordinato degli istruttori che hanno raccolto il maggior numero di partecipazioni ai loro corsi." << endl;
          query = "SELECT cognome, nome, SUM(num_partecipanti) AS partecipazioniTotali FROM partecipazioneCorsi, istruttore, atleta WHERE partecipazioneCorsi.istruttore = istruttore.cf AND istruttore.cf = atleta.cf GROUP BY cognome, nome ORDER BY partecipazioniTotali DESC;";
          break;
        case 2:
          cout << "Elenco ordinato degli enti che hanno registrato il maggior numero di infortuni in allenamento per una determinata fascia di ranking." << endl;
          query = "SELECT ente, COUNT(*) AS num_infortuni FROM dati_infortunio, pilota, atleta WHERE pilota.cf = atleta.cf AND dati_infortunio.pilota = pilota.cf AND ranking BETWEEN $1::int AND $2::int GROUP BY ente ORDER BY num_infortuni DESC;";
          break;
        case 3:
          cout << "Per ogni pilota determinare la pista che ha frequentato di maggiormente (in termini di eventi, corsi e allenamenti). Se un pilota ha frequentato maggiormente più piste (stesso numero di presenze), mostrare tutte le tuple." << endl;
          query = "SELECT * FROM presenzeTotali WHERE (pilota,presenze) IN (SELECT * FROM maxVisitePista) ORDER BY pilota;";
          break;
        case 4:
          cout << "Elenco dei piloti (e corrispettiva data) che hanno subito un infortunio lo stesso giorno in cui hanno fatto il loro giro più veloce in una pista." << endl;
          query = "SELECT g.pilota, a.data FROM giriVelociAssolutiPiloti g, allenamento a, infortunio i WHERE g.sessione = a.id AND i.sessione = a.id;";
          break;
        case 5:
          cout << "Per ogni circuito, restituire il miglior tempo assoluto, indicando anche il pilota che detiene il record." << endl;
          query = "SELECT circuito, cognome, nome, tempo_totale FROM (SELECT circuito, pilota, tempo_totale FROM giriVelociPiloti EXCEPT SELECT g1.circuito, g1.pilota, g1.tempo_totale FROM giriVelociPiloti g1, giriVelociPiloti g2 WHERE g1.circuito = g2.circuito AND g1.tempo_totale > g2.tempo_totale) AS g, pilota, atleta WHERE g.pilota = pilota.cf AND pilota.cf = atleta.cf ORDER BY circuito;";
          break;
        case 6:
          cout << "Trovare i membri del personale che sono anche piloti e che hanno eseguito un'operazione di manutenzione e un allenamento durante la stessa giornata." << endl;
          query = "SELECT p.cognome, p.nome, m.data FROM personale p, atleta a, pilota pi, allenamento al, manutenzione m WHERE p.cf = a.cf AND a.cf = pi.cf AND pi.cf = al.pilota AND p.cf = m.addetto and m.data = al.data ORDER BY p.cognome, p.nome;";
          break;
        default:
          break;
      }

      if (scelta == 2) {
        PGresult* stmt = PQprepare(conn, "query_enti", query.c_str(), 2, NULL);
        string min, max;
        bool exit = false;
        do {
          cout << "Inserisci il valore minimo per il ranking" << endl;
          cin >> min;
          cout << "Inserisci il valore massimo per il ranking" << endl;
          cin >> max;
          if (min <= max)
            exit = true;
          else
            cout << "Il valore minimo supera il valore massimo! Ripetere l'immissione!" << endl;
        } while (!exit);

        const char* const paramVal[] = {min.c_str(), max.c_str()};

        result = PQexecPrepared(conn, "query_enti", 2, paramVal, NULL, 0, 0);
      } else {
        result = PQexec(conn, query.c_str());
      }

      if (controlloRisultato(result, conn)) {
        int righe = PQntuples(result);
        int colonne = PQnfields(result);

        stampaIntestazione(40, result, colonne);
        stampaContenuto(40, result, colonne, righe);
        stampaChisura(40, colonne);
      }

      PQclear(result);
    } else {
      cout << "Numero di query inserito non valido!" << endl;
    }

    cout << "Digita 's' o 'S' per eseguire altre query o digita un altro carattere per uscire!" << endl;

    cin.clear();
    cin.ignore();

    cin >> continua;
  } while (continua == 's' || continua == 'S');

  cout << "Fine del programma!" << endl;
  PQfinish(conn);

  return 0;
}

/*
 * Controlla che la query sia stata eseguita con successo
*/
bool controlloRisultato(PGresult* res, const PGconn* conn) {
  bool ret;

  if (PQresultStatus(res) != PGRES_TUPLES_OK) {
    cout << "C'è stato un problema durante l'esecuzione della query! Errore: " << PQerrorMessage(conn) << endl;
    PQclear(res);
    ret = false;
  } else {
    cout << "Query eseguita correttamente!" << endl;
    ret = true;
  }
  return ret;
}

/*
 * Stampa l'intestazione della tabella associata alla query
*/
void stampaIntestazione(int dim, PGresult* result, int colonne) {
  cout << "┌";

  for (int i = 0; i < colonne - 1; ++i)
    cout << setw(39) << "───────────────────────────────────────┬";

  cout << "───────────────────────────────────────┐" << endl;

  cout << "│";

  string temp = PQfname(result, 0), spazi1, spazi2;
  int sz = temp.size();
  int aux1, aux2;
  aux1 = aux2 = (40 - sz) / 2;

  for (int i = 0; i < colonne; ++i) {
    temp = PQfname(result, i);
    sz = temp.size();
    aux1 = aux2 = (40 - sz) / 2;

    spazi1 = spazi2 = "";

    if (sz % 2 == 0)
      aux1--;

    for (int i = 0; i < aux1; i++)
      spazi1 += " ";

    for (int i = 0; i < aux2; i++)
      spazi2 += " ";

    cout << setw(aux1) << spazi1 << setw(sz) << temp << setw(aux2) << spazi2 << "│";
  }
  cout << endl;

  cout << "├";

  for (int i = 0; i < colonne - 1; ++i)
    cout << setw(39) << "───────────────────────────────────────┼";

  cout << "───────────────────────────────────────┤" << endl;
}

/*
 * Stampa le righe associate alla query
*/
void stampaContenuto(int dim, PGresult* result, int colonne, int righe) {
  string temp = PQfname(result, 0), spazi1, spazi2;
  int sz = temp.size();
  int aux1, aux2;
  aux1 = aux2 = (40 - sz) / 2;

  for (int i = 0; i < righe; ++i) {
    cout << "│";

    for (int j = 0; j < colonne; ++j) {
      temp = PQgetvalue(result, i, j);
      sz = temp.size();
      aux1 = aux2 = (40 - sz) / 2;

      spazi1 = spazi2 = "";

      if (sz % 2 == 0)
        aux1--;

      for (int i = 0; i < aux1; i++)
        spazi1 += " ";

      for (int i = 0; i < aux2; i++)
        spazi2 += " ";

      cout << setw(aux1) << spazi1 << setw(sz) << temp << setw(aux2) << spazi2 << "│";
    }
    cout << endl;
  }
}

/*
 * Stampa la chisura della tabella associata alla query
*/
void stampaChisura(int dim, int colonne) {
  cout << "└";

  for (int i = 0; i < colonne - 1; ++i)
    cout << setw(39) << "───────────────────────────────────────┴";

  cout << "───────────────────────────────────────┘" << endl;
}
