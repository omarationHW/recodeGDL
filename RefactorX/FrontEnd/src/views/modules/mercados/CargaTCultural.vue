<template>
  <div class="carga-tcultural-page">
    <h1>Carga de Pagos del Tianguis Cultural</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Carga TCultural</li>
      </ol>
    </nav>
    <form @submit.prevent="buscarAdeudos">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label>Folio Desde</label>
          <input v-model="form.local_desde" type="number" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label>Folio Hasta</label>
          <input v-model="form.local_hasta" type="number" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label>Periodo</label>
          <input v-model="form.periodo" type="number" min="1" max="4" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label>Año</label>
          <input v-model="form.axo" type="number" min="2007" max="2999" class="form-control" required />
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="adeudos.length">
      <h3>Adeudos Encontrados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>CONTROL</th>
            <th>LOCAL</th>
            <th>NOMBRE</th>
            <th>%DESC.</th>
            <th>AÑO</th>
            <th>TRIM.</th>
            <th>PAGO T.</th>
            <th>FECHA</th>
            <th>REC</th>
            <th>CAJA</th>
            <th>OPER.</th>
            <th>PARTIDA</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in pagos" :key="idx">
            <td>{{ row.id_local }}</td>
            <td>{{ row.local }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.descuento }}</td>
            <td>{{ row.axo }}</td>
            <td>{{ row.periodo }}</td>
            <td>{{ row.importe }}</td>
            <td><input v-model="row.fecha_pago" type="date" class="form-control form-control-sm" /></td>
            <td><input v-model="row.rec" type="number" class="form-control form-control-sm" /></td>
            <td><input v-model="row.caja" type="text" class="form-control form-control-sm" maxlength="2" /></td>
            <td><input v-model="row.operacion" type="number" class="form-control form-control-sm" /></td>
            <td><input v-model="row.partida" type="text" class="form-control form-control-sm" /></td>
          </tr>
        </tbody>
      </table>
      <div class="mb-2">
        <button class="btn btn-success" @click="validarPagos">Validar Folios</button>
        <button class="btn btn-primary ml-2" @click="guardarPagos" :disabled="!puedeGuardar">Guardar Pagos</button>
      </div>
      <div v-if="foliosErroneos.length" class="alert alert-danger">
        <strong>Folios erróneos:</strong> {{ foliosErroneos.join(', ') }}
      </div>
      <div v-if="mensaje" class="alert alert-info">{{ mensaje }}</div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'CargaTCultural',
  data() {
    return {
      form: {
        local_desde: '',
        local_hasta: '',
        periodo: 1,
        axo: new Date().getFullYear()
      },
      adeudos: [],
      pagos: [],
      foliosErroneos: [],
      mensaje: '',
      puedeGuardar: false
    };
  },
  methods: {
    async buscarAdeudos() {
      this.mensaje = '';
      this.foliosErroneos = [];
      this.puedeGuardar = false;
      this.adeudos = [];
      this.pagos = [];
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: 'getAdeudosTCultural',
          payload: this.form
        });
        if (data.eResponse.success) {
          this.adeudos = data.eResponse.data;
          // Map to pagos editable
          this.pagos = this.adeudos.map(row => ({
            id_local: row.id_local,
            local: row.local,
            nombre: row.nombre,
            descuento: row.descuento,
            axo: row.axo,
            periodo: row.periodo,
            importe: row.importe,
            fecha_pago: '',
            rec: '',
            caja: '',
            operacion: '',
            partida: ''
          }));
        } else {
          this.mensaje = data.eResponse.message || 'No se encontraron adeudos.';
        }
      } catch (e) {
        this.mensaje = 'Error al buscar adeudos: ' + e;
      }
    },
    async validarPagos() {
      this.mensaje = '';
      this.foliosErroneos = [];
      this.puedeGuardar = false;
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: 'validatePagosTCultural',
          payload: { pagos: this.pagos }
        });
        if (data.eResponse.success) {
          this.foliosErroneos = data.eResponse.data.foliosErroneos || [];
          if (this.foliosErroneos.length === 0) {
            this.mensaje = 'Todos los folios son válidos. Puede guardar.';
            this.puedeGuardar = true;
          } else {
            this.mensaje = 'Existen folios erróneos.';
          }
        } else {
          this.mensaje = data.eResponse.message;
        }
      } catch (e) {
        this.mensaje = 'Error al validar folios: ' + e;
      }
    },
    async guardarPagos() {
      this.mensaje = '';
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: 'savePagosTCultural',
          payload: { pagos: this.pagos }
        });
        if (data.eResponse.success) {
          this.mensaje = 'Pagos cargados correctamente.';
          this.buscarAdeudos();
        } else {
          this.mensaje = data.eResponse.message;
        }
      } catch (e) {
        this.mensaje = 'Error al guardar pagos: ' + e;
      }
    }
  }
};
</script>

<style scoped>
.carga-tcultural-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.table input {
  min-width: 60px;
}
</style>
