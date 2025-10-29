<template>
  <div class="aplica-sdos-favor">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / <span>Aplicar Saldos a Favor</span>
    </div>
    <h1>Aplicar Saldos a Favor</h1>
    <form @submit.prevent="buscarSolicitud">
      <div class="form-row">
        <label>Folio:</label>
        <input v-model="folio" type="number" required />
        <label>Año Folio:</label>
        <input v-model="axofol" type="number" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="solicitud">
      <h2>Datos de la Inconformidad</h2>
      <div class="info-grid">
        <div><strong>Recaudadora:</strong> {{ cuenta.recaud }}</div>
        <div><strong>U/R:</strong> {{ cuenta.urbrus }}</div>
        <div><strong>Cuenta:</strong> {{ cuenta.cuenta }}</div>
        <div><strong>Contribuyente:</strong> {{ contribuyente.ncompleto }}</div>
        <div><strong>Fecha Captura:</strong> {{ solicitud.feccap }}</div>
        <div><strong>Capturista:</strong> {{ solicitud.capturista }}</div>
        <div><strong>Estatus:</strong> <span :class="statusClass(solicitud.status)">{{ statusLabel(solicitud.status) }}</span></div>
      </div>
      <div class="saldo-favor">
        <h3>Saldo a Favor</h3>
        <div><strong>Importe:</strong> {{ sdosFavor ? sdosFavor.imp_inconform : '-' }}</div>
        <div><strong>Fecha Pago:</strong> {{ sdosFavor ? sdosFavor.fecha_pago : '-' }}</div>
        <div><strong>Saldo Favor:</strong> {{ sdosFavor ? sdosFavor.saldo_favor : '-' }}</div>
      </div>
      <div v-if="!sdosFavor">
        <button @click="altaSaldoFavor" :disabled="!importeAlta">Registrar Saldo a Favor</button>
        <input v-model.number="importeAlta" type="number" placeholder="Importe a favor" />
      </div>
      <div v-else>
        <div class="aplicar-form">
          <h3>Aplicar Saldo a Favor</h3>
          <form @submit.prevent="aplicarSaldoFavor">
            <div class="form-row">
              <label>Bimestre Inicial:</label>
              <input v-model.number="bimi" type="number" min="1" max="6" required />
              <label>Año Inicial:</label>
              <input v-model.number="axoi" type="number" required />
              <label>Bimestre Final:</label>
              <input v-model.number="bimf" type="number" min="1" max="6" required />
              <label>Año Final:</label>
              <input v-model.number="axof" type="number" required />
            </div>
            <div class="form-row">
              <label>Importe a Aplicar:</label>
              <input v-model.number="importeAplicar" type="number" required />
            </div>
            <button type="submit">Aplicar</button>
          </form>
        </div>
      </div>
      <div class="detalle-saldos">
        <h3>Detalle de Saldos</h3>
        <table>
          <thead>
            <tr>
              <th>Bim/Año</th>
              <th>Impuesto</th>
              <th>Recargos</th>
              <th>Saldo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="det in detalleSaldos" :key="det.bimsal + '-' + det.axosal">
              <td>{{ det.bimsal }}/{{ det.axosal }}</td>
              <td>{{ det.impade }}</td>
              <td>{{ det.recfac - det.recpag - det.recvir }}</td>
              <td>{{ det.saldo }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="success" class="success">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'AplicaSdosFavor',
  data() {
    return {
      folio: '',
      axofol: '',
      solicitud: null,
      cuenta: {},
      contribuyente: {},
      sdosFavor: null,
      detalleSaldos: [],
      error: '',
      success: '',
      importeAlta: '',
      bimi: '',
      axoi: '',
      bimf: '',
      axof: '',
      importeAplicar: ''
    };
  },
  methods: {
    async buscarSolicitud() {
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'buscarSolicitud',
          params: { folio: this.folio, axofol: this.axofol }
        });
        if (res.data.success) {
          this.solicitud = res.data.data.solicitud;
          this.cuenta = res.data.data.cuenta;
          this.contribuyente = res.data.data.contribuyente;
          this.sdosFavor = res.data.data.sdosFavor;
          this.detalleSaldos = await this.consultarDetalleSaldos(this.cuenta.cvecuenta);
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
    },
    async altaSaldoFavor() {
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'altaSaldoFavor',
          params: {
            id_solic: this.solicitud.id_solic,
            cvecuenta: this.cuenta.cvecuenta,
            importe: this.importeAlta,
            usuario: this.$store.state.user.username
          }
        });
        if (res.data.success) {
          this.success = 'Saldo a favor registrado correctamente';
          await this.buscarSolicitud();
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
    },
    async aplicarSaldoFavor() {
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'aplicarSaldoFavor',
          params: {
            id_solic: this.solicitud.id_solic,
            cvecuenta: this.cuenta.cvecuenta,
            bimi: this.bimi,
            axoi: this.axoi,
            bimf: this.bimf,
            axof: this.axof,
            importe: this.importeAplicar,
            usuario: this.$store.state.user.username
          }
        });
        if (res.data.success) {
          this.success = 'Saldo aplicado correctamente';
          await this.buscarSolicitud();
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
    },
    async consultarDetalleSaldos(cvecuenta) {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'consultarDetalleSaldos',
          params: { cvecuenta }
        });
        if (res.data.success) {
          return res.data.data;
        } else {
          this.error = res.data.message;
          return [];
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
        return [];
      }
    },
    statusLabel(status) {
      switch (status) {
        case 'P': return 'Pendiente';
        case 'C': return 'Cancelado';
        case 'T': return 'Terminado';
        case 'A': return 'Aplicado';
        default: return status;
      }
    },
    statusClass(status) {
      return {
        'status-pendiente': status === 'P',
        'status-cancelado': status === 'C',
        'status-terminado': status === 'T',
        'status-aplicado': status === 'A'
      };
    }
  }
};
</script>

<style scoped>
.aplica-sdos-favor {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.5rem 2rem;
  margin-bottom: 1rem;
}
.saldo-favor, .aplicar-form, .detalle-saldos {
  margin-bottom: 1.5rem;
}
.status-pendiente { color: orange; }
.status-cancelado { color: red; }
.status-terminado { color: green; }
.status-aplicado { color: blue; }
.error { color: red; margin-top: 1rem; }
.success { color: green; margin-top: 1rem; }
table { width: 100%; border-collapse: collapse; }
th, td { border: 1px solid #ccc; padding: 0.3rem 0.5rem; }
th { background: #f0f0f0; }
</style>
