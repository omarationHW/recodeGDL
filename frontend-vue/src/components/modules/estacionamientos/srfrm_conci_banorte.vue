<template>
  <div class="banorte-conciliacion">
    <router-view />
  </div>
</template>

<script>
// Este archivo es un wrapper para las páginas individuales
export default {
  name: 'BanorteConciliacion',
};
</script>

<!--
A continuación, se incluyen los componentes de página independientes:

1. Consulta por Folio: BanorteConciliacionFolio.vue
2. Consulta por Fecha: BanorteConciliacionFecha.vue
3. Cambiar Placa: BanorteConciliacionCambioPlaca.vue
4. Cambiar Folio: BanorteConciliacionCambioFolio.vue

Cada uno debe tener su propia ruta y archivo. Ejemplo de BanorteConciliacionFolio.vue:
-->

<!-- BanorteConciliacionFolio.vue -->
<template>
  <div>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Conciliación Banorte por Folio</li>
      </ol>
    </nav>
    <h2>Consulta de Conciliación de pagos por Banorte (Folio)</h2>
    <form @submit.prevent="buscar">
      <div class="form-group row">
        <label class="col-sm-2 col-form-label">Año:</label>
        <div class="col-sm-2">
          <input type="number" v-model="axo" :max="maxAxo" min="2002" class="form-control" required />
        </div>
        <label class="col-sm-2 col-form-label">Folio:</label>
        <div class="col-sm-2">
          <input type="number" v-model="folio" min="1" class="form-control" required />
        </div>
        <div class="col-sm-2">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="conciliados.length">
      <h4>Resultados</h4>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Estatus</th>
            <th>Año</th>
            <th>Folio</th>
            <th>Placa</th>
            <th>Placa Capturado por Banco</th>
            <th>Fecha folio</th>
            <th>Infracción</th>
            <th>Importe</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in conciliados" :key="row.rowid">
            <td>{{ row.stat }}</td>
            <td>{{ row.axo }}</td>
            <td>{{ row.folio }}</td>
            <td>{{ row.placa }}</td>
            <td>{{ row.placa_cambio }}</td>
            <td>{{ row.fecha_folio }}</td>
            <td>{{ row.infraccion }}</td>
            <td>{{ row.importe_neto }}</td>
            <td>
              <router-link :to="{ name: 'BanorteCambioPlaca', params: { rowid: row.rowid, axo: row.axo, folio: row.folio } }" class="btn btn-sm btn-warning">Cambiar Placa</router-link>
              <router-link :to="{ name: 'BanorteCambioFolio', params: { rowid: row.rowid, axo: row.axo, folio: row.folio } }" class="btn btn-sm btn-info ml-1">Cambiar Folio</router-link>
            </td>
          </tr>
        </tbody>
      </table>
      <h5>Historial</h5>
      <table class="table table-bordered table-sm" v-if="histo.length">
        <thead>
          <tr>
            <th>Fecha movto</th>
            <th>Año</th>
            <th>Folio</th>
            <th>Fecha folio</th>
            <th>Placa</th>
            <th>Infracción</th>
            <th>Fec_cap</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="h in histo" :key="h.control">
            <td>{{ h.fecha_movto }}</td>
            <td>{{ h.axo }}</td>
            <td>{{ h.folio }}</td>
            <td>{{ h.fecha_folio }}</td>
            <td>{{ h.placa }}</td>
            <td>{{ h.infraccion }}</td>
            <td>{{ h.fec_cap }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BanorteConciliacionFolio',
  data() {
    return {
      axo: '',
      folio: '',
      maxAxo: 2024,
      conciliados: [],
      histo: [],
      error: ''
    };
  },
  created() {
    this.getMaxAxo();
  },
  methods: {
    async getMaxAxo() {
      try {
        const res = await this.$axios.post('/api/execute', { eRequest: 'getMaxAxo' });
        this.maxAxo = res.data.eResponse.data.axo;
      } catch (e) {
        this.maxAxo = 2024;
      }
    },
    async buscar() {
      this.error = '';
      this.conciliados = [];
      this.histo = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'searchConciliadosByFolio',
          params: { axo: this.axo, folio: this.folio }
        });
        this.conciliados = res.data.eResponse.data || [];
        if (this.conciliados.length) {
          await this.getHisto(this.conciliados[0].axo, this.conciliados[0].folio);
        }
      } catch (e) {
        this.error = e.response?.data?.eResponse?.message || 'Error en la búsqueda';
      }
    },
    async getHisto(axo, folio) {
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'getHistoByAxoFolio',
          params: { axo, folio }
        });
        this.histo = res.data.eResponse.data || [];
      } catch (e) {
        this.histo = [];
      }
    }
  }
};
</script>

<style scoped>
.breadcrumb { background: #f8f9fa; }
</style>

<!--
Las otras páginas (BanorteConciliacionFecha.vue, BanorteConciliacionCambioPlaca.vue, BanorteConciliacionCambioFolio.vue) siguen la misma estructura, cambiando los formularios y llamadas a la API según corresponda.
-->
