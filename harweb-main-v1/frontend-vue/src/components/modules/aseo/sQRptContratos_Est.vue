<template>
  <div class="contratos-est-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estadística de Contratos</li>
      </ol>
    </nav>
    <h1>Estadística General de Contratos de Aseo</h1>
    <form @submit.prevent="fetchEstadistica">
      <div class="form-row mb-3">
        <div class="col-md-4">
          <label for="tipoAseo">Tipo de Aseo</label>
          <select v-model="form.cve_aseo" class="form-control" id="tipoAseo">
            <option value="T">Todos</option>
            <option v-for="t in tiposAseo" :key="t.ctrol_aseo" :value="t.tipo_aseo">{{ t.tipo_aseo }} - {{ t.descripcion }}</option>
          </select>
        </div>
        <div class="col-md-2">
          <label for="periodoDesde">Año Desde</label>
          <input type="number" v-model="form.aso_in" class="form-control" id="periodoDesde" min="2000" max="2100">
        </div>
        <div class="col-md-2">
          <label for="mesDesde">Mes Desde</label>
          <select v-model="form.mes_in" class="form-control" id="mesDesde">
            <option v-for="m in 12" :key="m" :value="m">{{ m }}</option>
          </select>
        </div>
        <div class="col-md-2">
          <label for="periodoHasta">Año Hasta</label>
          <input type="number" v-model="form.aso_fin" class="form-control" id="periodoHasta" min="2000" max="2100">
        </div>
        <div class="col-md-2">
          <label for="mesHasta">Mes Hasta</label>
          <select v-model="form.mes_fin" class="form-control" id="mesHasta">
            <option v-for="m in 12" :key="m" :value="m">{{ m }}</option>
          </select>
        </div>
      </div>
      <button type="submit" class="btn btn-primary">Consultar Estadística</button>
    </form>

    <div v-if="loading" class="mt-4">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-4">{{ error }}</div>

    <div v-if="estadistica && estadistica.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Tipo de Aseo</th>
            <th>Total Contratos</th>
            <th>Importe Total</th>
            <th>Cuota Normal</th>
            <th>Excedentes</th>
            <th>Contenedores</th>
            <th>Vigentes</th>
            <th>Cancelados</th>
            <th>Pagados</th>
            <th>Condonados</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in estadistica" :key="row.tipo_aseo">
            <td>{{ row.tipo_aseo }}</td>
            <td>{{ row.total_contratos }}</td>
            <td>{{ row.importe_total | currency }}</td>
            <td>{{ row.cuota_normal }}</td>
            <td>{{ row.excedentes }}</td>
            <td>{{ row.contenedores }}</td>
            <td>{{ row.vigentes }}</td>
            <td>{{ row.cancelados }}</td>
            <td>{{ row.pagados }}</td>
            <td>{{ row.condonados }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ContratosEstadisticaPage',
  data() {
    return {
      tiposAseo: [],
      estadistica: [],
      loading: false,
      error: '',
      form: {
        cve_aseo: 'T',
        aso_in: new Date().getFullYear(),
        mes_in: 1,
        aso_fin: new Date().getFullYear(),
        mes_fin: new Date().getMonth() + 1
      }
    }
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
      return val;
    }
  },
  created() {
    this.fetchTiposAseo();
  },
  methods: {
    async fetchTiposAseo() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'get_tipo_aseo' })
        });
        const data = await res.json();
        if (data.success) {
          this.tiposAseo = data.data;
        }
      } catch (e) {
        this.error = 'Error cargando tipos de aseo';
      }
    },
    async fetchEstadistica() {
      this.loading = true;
      this.error = '';
      this.estadistica = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'get_estadistica_periodo',
            params: {
              cve_aseo: this.form.cve_aseo,
              aso_in: this.form.aso_in,
              mes_in: this.form.mes_in,
              aso_fin: this.form.aso_fin,
              mes_fin: this.form.mes_fin
            }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.estadistica = data.data;
        } else {
          this.error = data.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = 'Error consultando estadística';
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.contratos-est-page {
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
