<template>
  <div class="folios-alta-page">
    <h1>Alta de Folios Nuevos</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Alta de Folios
    </div>
    <div class="form-section">
      <form @submit.prevent="onSubmit">
        <div class="row">
          <div class="col">
            <label>AÑO:</label>
            <span>{{ axo }}</span>
          </div>
          <div class="col">
            <label>Fecha de la multa:</label>
            <input type="date" v-model="form.fecha_folio" :min="minDate" :max="maxDate" required />
          </div>
          <div class="col">
            <label>Vigilante:</label>
            <select v-model="form.vigilante" required>
              <option v-for="v in vigilantes" :key="v.id_esta_persona" :value="v.id_esta_persona">{{ v.agente }}</option>
            </select>
          </div>
        </div>
        <div class="row">
          <div class="col">
            <label>Clave:</label>
            <select v-model="form.infraccion" required>
              <option v-for="c in infracciones" :key="c.num_clave" :value="c.num_clave">{{ c.descripcion }}</option>
            </select>
          </div>
          <div class="col">
            <label>Folio:</label>
            <input type="number" v-model.number="form.folio" min="1" max="99999999" @blur="checkFolio" required />
          </div>
          <div class="col">
            <label>Placa:</label>
            <input type="text" v-model="form.placa" maxlength="10" @blur="onPlacaBlur" required />
          </div>
          <div class="col">
            <label>Zona:</label>
            <input type="number" v-model.number="form.zona" min="0" max="99" required />
          </div>
          <div class="col">
            <label>Espacio:</label>
            <input type="number" v-model.number="form.espacio" min="0" max="99999" required />
          </div>
          <div class="col">
            <label>Hora:</label>
            <input type="time" v-model="form.hora" required />
          </div>
          <div class="col">
            <label>Estado:</label>
            <select v-model="form.estado" required>
              <option v-for="e in estados" :key="e.estado" :value="e.estado">{{ e.descripcion }}</option>
            </select>
          </div>
        </div>
        <div class="row">
          <div class="col">
            <button type="submit" :disabled="!canSubmit">Aceptar</button>
          </div>
        </div>
        <div v-if="message" class="message" :class="{'error': !success, 'success': success}">
          {{ message }}
        </div>
      </form>
    </div>
    <div class="vehiculo-section" v-if="vehiculo">
      <h3>Datos del Vehículo</h3>
      <ul>
        <li><strong>Marca:</strong> {{ vehiculo.marca }}</li>
        <li><strong>Modelo:</strong> {{ vehiculo.modelo }}</li>
        <li><strong>Color:</strong> {{ vehiculo.color }}</li>
      </ul>
    </div>
    <div class="calcomania-section" v-if="calcomania">
      <h3>Calcomanía Vigente</h3>
      <ul>
        <li><strong>No. Calcomanía:</strong> {{ calcomania.num_calco }}</li>
        <li><strong>Turno:</strong> {{ calcomania.turno }}</li>
        <li><strong>Periodo Inicial:</strong> {{ calcomania.fecha_inicial }}</li>
        <li><strong>Periodo Final:</strong> {{ calcomania.fecha_fin }}</li>
      </ul>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'FoliosAltaPage',
  data() {
    return {
      axo: '',
      minDate: '',
      maxDate: '',
      infracciones: [],
      estados: [],
      vigilantes: [],
      vehiculo: null,
      calcomania: null,
      message: '',
      success: false,
      canSubmit: false,
      form: {
        axo: '',
        folio: '',
        fecha_folio: '',
        placa: '',
        infraccion: '',
        estado: '',
        vigilante: '',
        usu_inicial: 1, // Simulación usuario logueado
        zona: 0,
        espacio: 0,
        hora: ''
      }
    };
  },
  created() {
    this.loadCatalogs();
  },
  methods: {
    async loadCatalogs() {
      // Año de captura
      let axoResp = await axios.post('/api/execute', { eRequest: 'get_axo_captura' });
      this.axo = axoResp.data.eResponse.data[0]?.axo || '';
      this.form.axo = this.axo;
      // Fechas mínimas y máximas
      this.minDate = this.axo ? `${this.axo}-01-01` : '';
      this.maxDate = this.axo ? `${this.axo}-12-31` : '';
      this.form.fecha_folio = new Date().toISOString().substr(0, 10);
      // Infracciones
      let infResp = await axios.post('/api/execute', { eRequest: 'get_infracciones' });
      this.infracciones = infResp.data.eResponse.data;
      // Estados
      let estResp = await axios.post('/api/execute', { eRequest: 'get_estados' });
      this.estados = estResp.data.eResponse.data;
      // Vigilantes
      let vigResp = await axios.post('/api/execute', { eRequest: 'get_vigilantes' });
      this.vigilantes = vigResp.data.eResponse.data;
    },
    async checkFolio() {
      this.message = '';
      this.success = false;
      this.canSubmit = false;
      if (!this.form.folio || !this.form.axo) return;
      // Verifica si folio ya existe en adeudo
      let resp = await axios.post('/api/execute', {
        eRequest: 'get_folio_adeudo',
        params: { axo: this.form.axo, folio: this.form.folio }
      });
      if (resp.data.eResponse.data && resp.data.eResponse.data.length > 0) {
        this.message = 'Folio ya está capturado vigente...';
        this.success = false;
        return;
      }
      // Verifica si folio está en histórico
      let resp2 = await axios.post('/api/execute', {
        eRequest: 'get_folio_histo',
        params: { axo: this.form.axo, folio: this.form.folio }
      });
      if (resp2.data.eResponse.data && resp2.data.eResponse.data.length > 0) {
        this.message = 'Folio Pagado o sin efecto...';
        this.success = false;
        return;
      }
      this.message = '';
      this.success = true;
      this.canSubmit = true;
    },
    async onPlacaBlur() {
      this.vehiculo = null;
      this.calcomania = null;
      if (!this.form.placa || this.form.placa.length < 7) return;
      // Calcomanía vigente
      let calcoResp = await axios.post('/api/execute', {
        eRequest: 'get_calcomania',
        params: { placa: this.form.placa, fecha: this.form.fecha_folio }
      });
      if (calcoResp.data.eResponse.data && calcoResp.data.eResponse.data.length > 0) {
        this.calcomania = calcoResp.data.eResponse.data[0];
        this.message = `Calcomania No. ${this.calcomania.num_calco}  Turno: ${this.calcomania.turno}  Periodo Inicial: ${this.calcomania.fecha_inicial}  Periodo final: ${this.calcomania.fecha_fin}`;
        this.success = true;
      }
      // Datos del vehículo
      let vehResp = await axios.post('/api/execute', {
        eRequest: 'get_padron_vehiculo',
        params: { placa: this.form.placa }
      });
      if (vehResp.data.eResponse.data && vehResp.data.eResponse.data.length > 0) {
        this.vehiculo = vehResp.data.eResponse.data[0];
      }
    },
    async onSubmit() {
      this.message = '';
      this.success = false;
      // Validación básica
      if (!this.canSubmit) {
        this.message = 'Verifique los datos antes de grabar.';
        return;
      }
      // Inserta folio
      let resp = await axios.post('/api/execute', {
        eRequest: 'insert_folio_adeudo',
        params: {
          axo: this.form.axo,
          folio: this.form.folio,
          fecha_folio: this.form.fecha_folio,
          placa: this.form.placa,
          infraccion: this.form.infraccion,
          estado: this.form.estado,
          vigilante: this.form.vigilante,
          usu_inicial: this.form.usu_inicial,
          zona: this.form.zona,
          espacio: this.form.espacio
        }
      });
      if (resp.data.eResponse.success) {
        this.message = `Ultimo folio Grabado: ${this.form.folio}     Placa: ${this.form.placa}`;
        this.success = true;
        this.form.folio = parseInt(this.form.folio) + 1;
        this.canSubmit = false;
      } else {
        this.message = resp.data.eResponse.message || 'Error al grabar folio.';
        this.success = false;
      }
    }
  }
};
</script>

<style scoped>
.folios-alta-page {
  max-width: 900px;
  margin: 0 auto;
  background: #f9f9f9;
  padding: 2em;
  border-radius: 8px;
}
.breadcrumb {
  margin-bottom: 1em;
  font-size: 0.95em;
  color: #888;
}
.form-section {
  background: #fff;
  padding: 1em 2em;
  border-radius: 6px;
  margin-bottom: 1.5em;
}
.row {
  display: flex;
  flex-wrap: wrap;
  margin-bottom: 1em;
}
.col {
  flex: 1 1 180px;
  margin-right: 1em;
  margin-bottom: 0.5em;
}
.col label {
  display: block;
  font-weight: bold;
  margin-bottom: 0.2em;
}
.message {
  margin-top: 1em;
  padding: 0.7em;
  border-radius: 4px;
}
.message.error {
  background: #ffe0e0;
  color: #a00;
}
.message.success {
  background: #e0ffe0;
  color: #080;
}
.vehiculo-section, .calcomania-section {
  background: #fff;
  padding: 1em 2em;
  border-radius: 6px;
  margin-bottom: 1em;
}
</style>
