<template>
  <div class="estad-adeudo-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estadísticos y Listados de Adeudos</li>
      </ol>
    </nav>
    <h1 class="mb-4">Estadísticos y Listados de Adeudos</h1>
    <div class="card mb-4">
      <div class="card-body">
        <div class="row">
          <div class="col-md-4">
            <h5>Tipo Reporte</h5>
            <div class="form-check">
              <input class="form-check-input" type="radio" id="resumen" value="resumen" v-model="tipoReporte">
              <label class="form-check-label" for="resumen">Resumen</label>
            </div>
            <div class="form-check">
              <input class="form-check-input" type="radio" id="listado" value="listado" v-model="tipoReporte">
              <label class="form-check-label" for="listado">Listado de adeudos</label>
            </div>
          </div>
          <div class="col-md-8" v-if="tipoReporte === 'listado'">
            <h5>Adeudos</h5>
            <div class="form-check" v-for="(label, idx) in opcionesAnios" :key="idx">
              <input class="form-check-input" type="radio" :id="'anio' + idx" :value="label.value" v-model="aniosFiltro">
              <label class="form-check-label" :for="'anio' + idx">{{ label.text }}</label>
            </div>
          </div>
        </div>
        <div class="mt-4">
          <button class="btn btn-primary me-2" @click="consultar" :disabled="loading">
            <span v-if="loading" class="spinner-border spinner-border-sm"></span>
            Procesar Información
          </button>
          <button class="btn btn-secondary" @click="$router.back()">Salir</button>
        </div>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="tipoReporte === 'resumen' && resumen.length">
      <h3>Resumen de Adeudos</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Cementerio</th>
            <th>Último Año de Pago</th>
            <th>Total Registros</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in resumen" :key="row.cementerio + '-' + row.uap">
            <td>{{ row.cementerio }}</td>
            <td>{{ row.uap }}</td>
            <td>{{ row.cuenta }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="tipoReporte === 'listado' && listado.length">
      <h3>Listado de Adeudos</h3>
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th>Folio</th>
              <th>Cementerio</th>
              <th>Clase</th>
              <th>Clase Alfa</th>
              <th>Sección</th>
              <th>Sección Alfa</th>
              <th>Línea</th>
              <th>Línea Alfa</th>
              <th>Fosa</th>
              <th>Fosa Alfa</th>
              <th>Último Año Pago</th>
              <th>Metros</th>
              <th>Nombre</th>
              <th>Domicilio</th>
              <th>Exterior</th>
              <th>Interior</th>
              <th>Colonia</th>
              <th>Observaciones</th>
              <th>Usuario</th>
              <th>Fecha Mov</th>
              <th>Tipo</th>
              <th>Cementerio Nombre</th>
              <th>Usuario Nombre</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in listado" :key="row.control_rcm">
              <td>{{ row.control_rcm }}</td>
              <td>{{ row.cementerio }}</td>
              <td>{{ row.clase }}</td>
              <td>{{ row.clase_alfa }}</td>
              <td>{{ row.seccion }}</td>
              <td>{{ row.seccion_alfa }}</td>
              <td>{{ row.linea }}</td>
              <td>{{ row.linea_alfa }}</td>
              <td>{{ row.fosa }}</td>
              <td>{{ row.fosa_alfa }}</td>
              <td>{{ row.axo_pagado }}</td>
              <td>{{ row.metros }}</td>
              <td>{{ row.nombre }}</td>
              <td>{{ row.domicilio }}</td>
              <td>{{ row.exterior }}</td>
              <td>{{ row.interior }}</td>
              <td>{{ row.colonia }}</td>
              <td>{{ row.observaciones }}</td>
              <td>{{ row.nombre_2 }}</td>
              <td>{{ row.fecha_mov ? row.fecha_mov.substring(0,10) : '' }}</td>
              <td>{{ row.tipo }}</td>
              <td>{{ row.nombre_1 }}</td>
              <td>{{ row.nombre_2 }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="!loading && (tipoReporte === 'resumen' && resumen.length === 0 || tipoReporte === 'listado' && listado.length === 0) && !error" class="alert alert-info">
      No hay datos para mostrar.
    </div>
  </div>
</template>

<script>
export default {
  name: 'EstadAdeudoPage',
  data() {
    return {
      tipoReporte: 'resumen',
      aniosFiltro: 5,
      opcionesAnios: [
        { value: 5, text: 'Con adeudos > 4 años' },
        { value: 4, text: 'Con adeudos > 3 años' },
        { value: 3, text: 'Con adeudos > 2 años' },
        { value: 2, text: 'Con adeudos > 1 años' },
        { value: 1, text: 'Con adeudos del año en curso' }
      ],
      resumen: [],
      listado: [],
      loading: false,
      error: ''
    }
  },
  methods: {
    async consultar() {
      this.error = '';
      this.resumen = [];
      this.listado = [];
      this.loading = true;
      try {
        if (this.tipoReporte === 'resumen') {
          const resp = await this.$axios.post('/api/execute', {
            eRequest: { action: 'getResumen' }
          });
          if (resp.data.eResponse.success) {
            this.resumen = resp.data.eResponse.data;
          } else {
            this.error = resp.data.eResponse.message || 'Error al consultar resumen';
          }
        } else {
          const resp = await this.$axios.post('/api/execute', {
            eRequest: { action: 'getListado', params: { axop: this.aniosFiltro } }
          });
          if (resp.data.eResponse.success) {
            this.listado = resp.data.eResponse.data;
          } else {
            this.error = resp.data.eResponse.message || 'Error al consultar listado';
          }
        }
      } catch (e) {
        this.error = e.response?.data?.eResponse?.message || e.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    }
  },
  mounted() {
    this.consultar();
  }
}
</script>

<style scoped>
.estad-adeudo-page {
  max-width: 1200px;
  margin: 0 auto;
}
</style>
