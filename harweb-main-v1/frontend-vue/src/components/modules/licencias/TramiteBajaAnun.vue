<template>
  <div class="tramite-baja-anun-page">
    <h1>Trámite de Baja de Anuncio</h1>
    <form @submit.prevent="buscarAnuncio">
      <div class="form-group">
        <label for="anuncio">No. de anuncio:</label>
        <input v-model="form.anuncio" id="anuncio" type="number" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="anuncio">
      <h2>Datos del Anuncio</h2>
      <div class="anuncio-info">
        <p><strong>Licencia de referencia:</strong> {{ anuncio.id_licencia }}</p>
        <p><strong>Fecha de otorgamiento:</strong> {{ anuncio.fecha_otorgamiento }}</p>
        <p><strong>Propietario:</strong> {{ licencia ? licencia.propietarionvo : '' }}</p>
        <p><strong>Teléfono:</strong> {{ licencia ? licencia.telefono_prop : '' }}</p>
        <p><strong>Medidas:</strong> {{ anuncio.medidas1 }} por {{ anuncio.medidas2 }} | Área: {{ anuncio.area_anuncio }}</p>
        <p><strong>Ubicación:</strong> {{ anuncio.ubicacion }} No. ext: {{ anuncio.numext_ubic }} letra ext: {{ anuncio.letraext_ubic }} No. int: {{ anuncio.numint_ubic }} letra int: {{ anuncio.letraint_ubic }}</p>
      </div>
      <div v-if="saldos && saldos.length">
        <h3>Adeudos</h3>
        <table class="table">
          <thead>
            <tr>
              <th>Año</th>
              <th>Saldo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="s in saldos" :key="s.axo">
              <td>{{ s.axo }}</td>
              <td>{{ s.saldo }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <form @submit.prevent="tramitarBaja">
        <div class="form-group">
          <label for="motivo">Motivo de la baja:</label>
          <input v-model="form.motivo" id="motivo" type="text" required />
        </div>
        <div class="form-group">
          <label><input type="checkbox" v-model="form.baja_error" /> Baja por error</label>
          <label><input type="checkbox" v-model="form.baja_tiempo" /> Baja en tiempo</label>
        </div>
        <button type="submit" :disabled="!anuncio || loading">Tramitar Baja</button>
      </form>
      <div v-if="resultMessage" class="result-message">{{ resultMessage }}</div>
    </div>
    <div v-if="errorMessage" class="error-message">{{ errorMessage }}</div>
  </div>
</template>

<script>
export default {
  name: 'TramiteBajaAnunPage',
  data() {
    return {
      form: {
        anuncio: '',
        motivo: '',
        baja_error: false,
        baja_tiempo: false
      },
      anuncio: null,
      licencia: null,
      saldos: [],
      loading: false,
      resultMessage: '',
      errorMessage: ''
    };
  },
  methods: {
    async buscarAnuncio() {
      this.loading = true;
      this.resultMessage = '';
      this.errorMessage = '';
      this.anuncio = null;
      this.licencia = null;
      this.saldos = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.buscarAnuncio',
          payload: { anuncio: this.form.anuncio }
        });
        if (res.data.status === 'success') {
          this.anuncio = res.data.eResponse.data.result.anuncio;
          this.licencia = res.data.eResponse.data.result.licencia;
          this.saldos = res.data.eResponse.data.result.saldos;
        } else {
          this.errorMessage = res.data.message || 'No se encontró el anuncio';
        }
      } catch (error) {
        this.errorMessage = 'Error de conexión';
      }
      this.loading = false;
    },
    async tramitarBaja() {
      if (!this.anuncio) return;
      this.loading = true;
      this.resultMessage = '';
      this.errorMessage = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.tramitarBaja',
          payload: {
            anuncio: this.anuncio.anuncio,
            motivo: this.form.motivo,
            usuario: this.$store.state.usuario || 'usuario_demo',
            axo_baja: new Date().getFullYear(),
            folio_baja: 0 // Puede ser calculado por backend
          }
        });
        if (res.data.status === 'success') {
          this.resultMessage = 'Baja tramitada correctamente';
          this.anuncio = null;
          this.licencia = null;
          this.saldos = [];
          this.form.motivo = '';
        } else {
          this.errorMessage = res.data.message || 'No se pudo tramitar la baja';
        }
      } catch (error) {
        this.errorMessage = 'Error de conexión';
      }
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.tramite-baja-anun-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.form-group {
  margin-bottom: 1rem;
}
.result-message {
  color: green;
  margin-top: 1rem;
}
.error-message {
  color: red;
  margin-top: 1rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.table th, .table td {
  border: 1px solid #eee;
  padding: 0.5rem;
}
</style>
