<template>
  <div class="requerimientos-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Emisión de Requerimientos</li>
      </ol>
    </nav>
    <h1>Emisión de Requerimientos</h1>
    <form @submit.prevent="onBuscar">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label>Aplicación</label>
          <select v-model="aplicacion" class="form-control">
            <option value="mercado">Mercados</option>
            <option value="aseo">Aseo</option>
            <option value="publicos">Estacionamientos Públicos</option>
          </select>
        </div>
        <div class="form-group col-md-3" v-if="aplicacion==='mercado'">
          <label>Mercado</label>
          <select v-model="filtros.mercado" class="form-control">
            <option v-for="m in mercados" :key="m.id" :value="m.id">{{ m.descripcion }}</option>
          </select>
        </div>
        <div class="form-group col-md-3" v-if="aplicacion==='aseo'">
          <label>Tipo de Aseo</label>
          <select v-model="filtros.tipo_aseo" class="form-control">
            <option v-for="t in tiposAseo" :key="t.ctrol_aseo" :value="t.tipo_aseo">{{ t.descripcion }}</option>
          </select>
        </div>
        <!-- Otros filtros según aplicación -->
      </div>
      <div class="form-row">
        <div class="form-group col-md-2">
          <label>Desde</label>
          <input v-model.number="filtros.desde" type="number" class="form-control" />
        </div>
        <div class="form-group col-md-2">
          <label>Hasta</label>
          <input v-model.number="filtros.hasta" type="number" class="form-control" />
        </div>
        <div class="form-group col-md-2">
          <label>Importe Adeudo Desde</label>
          <input v-model.number="filtros.adeudo_desde" type="number" class="form-control" />
        </div>
        <div class="form-group col-md-2">
          <label>Importe Adeudo Hasta</label>
          <input v-model.number="filtros.adeudo_hasta" type="number" class="form-control" />
        </div>
      </div>
      <button type="submit" class="btn btn-primary">Buscar</button>
    </form>
    <div v-if="loading" class="mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="resultados && resultados.length" class="mt-3">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th v-for="col in columnas" :key="col">{{ col }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in resultados" :key="row.id">
            <td v-for="col in columnas" :key="col">{{ row[col] }}</td>
          </tr>
        </tbody>
      </table>
      <button class="btn btn-success" @click="emitirRequerimientos">Emitir Requerimientos</button>
    </div>
    <div v-if="emisionResult" class="alert alert-info mt-3">
      {{ emisionResult }}
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'RequerimientosPage',
  data() {
    return {
      aplicacion: 'mercado',
      filtros: {
        mercado: '',
        tipo_aseo: '',
        desde: '',
        hasta: '',
        adeudo_desde: '',
        adeudo_hasta: ''
      },
      mercados: [],
      tiposAseo: [],
      resultados: [],
      columnas: [],
      loading: false,
      error: '',
      emisionResult: ''
    };
  },
  created() {
    this.cargarCatalogos();
  },
  methods: {
    async cargarCatalogos() {
      // Cargar mercados y tipos de aseo
      try {
        let res = await axios.post('/api/execute', { eRequest: { action: 'getMercados', params: { user_id: 1 } } });
        this.mercados = res.data.eResponse.data;
        res = await axios.post('/api/execute', { eRequest: { action: 'getTiposAseo', params: {} } });
        this.tiposAseo = res.data.eResponse.data;
      } catch (e) {
        this.error = 'Error cargando catálogos';
      }
    },
    async onBuscar() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      this.emisionResult = '';
      let action = '';
      let params = {};
      if (this.aplicacion === 'mercado') {
        action = 'buscarMercadosAdeudos';
        params = {
          oficina: this.filtros.mercado,
          num_mercado_desde: this.filtros.desde,
          num_mercado_hasta: this.filtros.hasta,
          local_desde: 1,
          local_hasta: 9999,
          seccion: '',
          filtro_tipo: '',
          filtro_valor: '',
          adeudo_desde: this.filtros.adeudo_desde,
          adeudo_hasta: this.filtros.adeudo_hasta,
          user_id: 1
        };
      } else if (this.aplicacion === 'aseo') {
        action = 'buscarAseoAdeudos';
        params = {
          tipo_aseo: this.filtros.tipo_aseo,
          contrato_desde: this.filtros.desde,
          contrato_hasta: this.filtros.hasta,
          filtro_tipo: '',
          filtro_valor: '',
          adeudo_desde: this.filtros.adeudo_desde,
          adeudo_hasta: this.filtros.adeudo_hasta,
          user_id: 1
        };
      } else {
        // públicos, etc.
        this.error = 'Funcionalidad no implementada';
        this.loading = false;
        return;
      }
      try {
        const res = await axios.post('/api/execute', { eRequest: { action, params } });
        if (res.data.eResponse.success) {
          this.resultados = res.data.eResponse.data;
          this.columnas = this.resultados.length ? Object.keys(this.resultados[0]) : [];
        } else {
          this.error = res.data.eResponse.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = 'Error en la consulta';
      }
      this.loading = false;
    },
    async emitirRequerimientos() {
      this.loading = true;
      this.emisionResult = '';
      let action = '';
      let params = {};
      if (this.aplicacion === 'mercado') {
        action = 'emitirRequerimientosMercado';
        params = {
          oficina: this.filtros.mercado,
          num_mercado_desde: this.filtros.desde,
          num_mercado_hasta: this.filtros.hasta,
          local_desde: 1,
          local_hasta: 9999,
          seccion: '',
          filtro_tipo: '',
          filtro_valor: '',
          adeudo_desde: this.filtros.adeudo_desde,
          adeudo_hasta: this.filtros.adeudo_hasta,
          user_id: 1
        };
      } else if (this.aplicacion === 'aseo') {
        action = 'emitirRequerimientosAseo';
        params = {
          tipo_aseo: this.filtros.tipo_aseo,
          contrato_desde: this.filtros.desde,
          contrato_hasta: this.filtros.hasta,
          filtro_tipo: '',
          filtro_valor: '',
          adeudo_desde: this.filtros.adeudo_desde,
          adeudo_hasta: this.filtros.adeudo_hasta,
          user_id: 1
        };
      } else {
        this.error = 'Funcionalidad no implementada';
        this.loading = false;
        return;
      }
      try {
        const res = await axios.post('/api/execute', { eRequest: { action, params } });
        if (res.data.eResponse.success) {
          this.emisionResult = 'Requerimientos emitidos correctamente.';
        } else {
          this.emisionResult = res.data.eResponse.message || 'Error al emitir requerimientos';
        }
      } catch (e) {
        this.emisionResult = 'Error al emitir requerimientos';
      }
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.requerimientos-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
