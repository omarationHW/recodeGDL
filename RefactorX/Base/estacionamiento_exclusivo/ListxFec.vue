<template>
  <div class="listx-fec-page">
    <h1>Listado de Requerimientos por Fechas</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listados por Fechas</li>
      </ol>
    </nav>
    <form @submit.prevent="onSubmit">
      <div class="row">
        <div class="col-md-4">
          <label>Aplicación</label>
          <select v-model="form.modulo" class="form-control">
            <option :value="11">Mercados</option>
            <option :value="16">Aseo</option>
            <option :value="24">Estacionamientos Públicos</option>
            <option :value="28">Estacionamientos Exclusivos</option>
            <option :value="14">Estacionómetros</option>
            <option :value="13">Cementerios</option>
          </select>
        </div>
        <div class="col-md-4">
          <label>Tipo de Fecha</label>
          <select v-model="form.tipo_fecha" class="form-control">
            <option :value="1">Actualización</option>
            <option :value="2">Practicado</option>
            <option :value="3">Citado</option>
            <option :value="4">Pago</option>
            <option :value="5">Emisión</option>
            <option :value="6">Entrega</option>
          </select>
        </div>
        <div class="col-md-4">
          <label>Vigencia</label>
          <select v-model="form.vigencia" class="form-control">
            <option value="todas">Todas</option>
            <option v-for="v in vigencias" :key="v.clave" :value="v.clave">{{ v.clave }} - {{ v.descrip }}</option>
          </select>
        </div>
      </div>
      <div class="row mt-3">
        <div class="col-md-3">
          <label>Fecha Desde</label>
          <input type="date" v-model="form.fecha1" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label>Fecha Hasta</label>
          <input type="date" v-model="form.fecha2" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label>Recaudadora</label>
          <select v-model="form.rec" class="form-control">
            <option v-for="r in recaudadoras" :key="r.id_rec" :value="r.id_rec">{{ r.id_rec }} - {{ r.recaudadora }}</option>
          </select>
        </div>
        <div class="col-md-3">
          <label>Ejecutor</label>
          <select v-model="form.ejecutor" class="form-control">
            <option value="todos">Todos</option>
            <option v-for="e in ejecutores" :key="e.cve_eje" :value="e.cve_eje">{{ e.cve_eje }} - {{ e.nombre }}</option>
          </select>
        </div>
      </div>
      <div class="row mt-4">
        <div class="col-md-12 text-right">
          <button type="submit" class="btn btn-primary">Generar Reporte</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="mt-4 alert alert-info">Cargando...</div>
    <div v-if="error" class="mt-4 alert alert-danger">{{ error }}</div>
    <div v-if="report.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm table-hover">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Fecha</th>
            <th>Ejecutor</th>
            <th>Vigencia</th>
            <th>Importe</th>
            <th>Datos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.folio">
            <td>{{ row.folio }}</td>
            <td>{{ row.fecha }}</td>
            <td>{{ row.ejecutor_nombre }}</td>
            <td>{{ row.vigencia }}</td>
            <td>{{ row.importe_global }}</td>
            <td>{{ row.datos }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ListxFecPage',
  data() {
    return {
      form: {
        modulo: 11,
        tipo_fecha: 1,
        fecha1: '',
        fecha2: '',
        vigencia: 'todas',
        rec: '',
        ejecutor: 'todos'
      },
      vigencias: [],
      recaudadoras: [],
      ejecutores: [],
      report: [],
      loading: false,
      error: ''
    };
  },
  created() {
    this.loadVigencias();
    this.loadRecaudadoras();
  },
  watch: {
    'form.rec'(val) {
      if (val) this.loadEjecutores(val);
    }
  },
  methods: {
    async loadVigencias() {
      const res = await this.api('getVigencias');
      if (res.status === 'ok') this.vigencias = res.data;
    },
    async loadRecaudadoras() {
      const res = await this.api('getRecaudadoras');
      if (res.status === 'ok') {
        this.recaudadoras = res.data;
        if (!this.form.rec && res.data.length) this.form.rec = res.data[0].id_rec;
      }
    },
    async loadEjecutores(rec) {
      const res = await this.api('getEjecutores', { rec });
      if (res.status === 'ok') this.ejecutores = res.data;
    },
    async onSubmit() {
      this.loading = true;
      this.error = '';
      this.report = [];
      const res = await this.api('getReport', {
        rec: this.form.rec,
        modulo: this.form.modulo,
        tipo_fecha: this.form.tipo_fecha,
        fecha1: this.form.fecha1,
        fecha2: this.form.fecha2,
        vigencia: this.form.vigencia,
        ejecutor: this.form.ejecutor
      });
      this.loading = false;
      if (res.status === 'ok') {
        this.report = res.data;
      } else {
        this.error = res.message || 'Error al obtener reporte';
      }
    },
    async api(action, params = {}) {
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action, params })
        });
        return await resp.json();
      } catch (e) {
        return { status: 'error', message: e.message };
      }
    }
  }
};
</script>

<style scoped>
.listx-fec-page {
  max-width: 900px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
.breadcrumb {
  background: transparent;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
