<template>
  <div class="rprt-catal-eje-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Ejecutores</li>
      </ol>
    </nav>
    <div class="card mb-4">
      <div class="card-header">
        <img src="/logo_guadalajara.png" alt="Logo" style="height: 48px; margin-right: 16px;" />
        <span class="h5 align-middle">TESORERIA MUNICIPAL DE GUADALAJARA</span>
        <br />
        <span class="h6 align-middle">DIRECCION DE INGRESOS MUNICIPALES</span>
        <br />
        <span class="h6 align-middle">LISTADO DE EJECUTORES</span>
      </div>
      <div class="card-body">
        <form class="form-inline mb-3" @submit.prevent="fetchData">
          <div class="form-group mr-3">
            <label for="id_rec" class="mr-2">ID Recaudadora:</label>
            <input type="number" v-model="filters.id_rec" id="id_rec" class="form-control" required />
          </div>
          <div class="form-group mr-3">
            <label for="vigencia" class="mr-2">Vigencia:</label>
            <select v-model="filters.vigencia" id="vigencia" class="form-control">
              <option value="">Todos</option>
              <option value="A">Activos</option>
              <option value="I">Inactivos</option>
            </select>
          </div>
          <button type="submit" class="btn btn-primary">Buscar</button>
        </form>
        <div v-if="loading" class="text-center my-4">
          <span class="spinner-border"></span> Cargando...
        </div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <table v-if="!loading && ejecutores.length" class="table table-bordered table-striped table-sm">
          <thead class="thead-light">
            <tr>
              <th>CLAVE</th>
              <th>RFC</th>
              <th>NOMBRE</th>
              <th>OFICIO</th>
              <th>INIC. FECHA DET</th>
              <th>INICIO</th>
              <th>TERMINO</th>
              <th>RECAUDADORA</th>
              <th>ZONA</th>
              <th>VIGENCIA</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="ejecutor in ejecutores" :key="ejecutor.id_ejecutor">
              <td>{{ ejecutor.cve_eje }}</td>
              <td>{{ ejecutor.ini_rfc }}{{ ejecutor.fec_rfc ? formatDate(ejecutor.fec_rfc) : '' }}{{ ejecutor.hom_rfc }}</td>
              <td>{{ ejecutor.nombre }}</td>
              <td>{{ ejecutor.oficio }}</td>
              <td>{{ ejecutor.ini_rfc }} {{ formatDate(ejecutor.fec_rfc) }} {{ ejecutor.hom_rfc }}</td>
              <td>{{ formatDate(ejecutor.fecinic) }}</td>
              <td>{{ formatDate(ejecutor.fecterm) }}</td>
              <td>{{ ejecutor.recaudadora_1 }}</td>
              <td>{{ ejecutor.zona }}</td>
              <td>{{ ejecutor.vigencia }}</td>
            </tr>
          </tbody>
        </table>
        <div v-if="!loading && ejecutores.length" class="mt-3">
          <strong>Total de ejecutores: {{ ejecutores.length }}</strong>
        </div>
        <div v-if="!loading && !ejecutores.length" class="alert alert-info">
          No se encontraron ejecutores para los filtros seleccionados.
        </div>
      </div>
      <div class="card-footer text-right">
        <small>Guadalajara, Jal. a {{ today }}</small>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'RprtCatalEjePage',
  data() {
    return {
      filters: {
        id_rec: '',
        vigencia: ''
      },
      ejecutores: [],
      loading: false,
      error: '',
      today: new Date().toLocaleDateString('es-MX')
    };
  },
  methods: {
    fetchData() {
      this.loading = true;
      this.error = '';
      this.ejecutores = [];
      axios.post('/api/execute', {
        eRequest: 'RprtCATAL_EJE.list',
        params: {
          id_rec: this.filters.id_rec,
          vigencia: this.filters.vigencia
        }
      })
      .then(res => {
        if (res.data.eResponse.success) {
          this.ejecutores = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error al obtener datos';
        }
      })
      .catch(err => {
        this.error = err.response?.data?.eResponse?.message || err.message;
      })
      .finally(() => {
        this.loading = false;
      });
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      if (isNaN(d)) return dateStr;
      return d.toLocaleDateString('es-MX');
    }
  }
};
</script>

<style scoped>
.rprt-catal-eje-page {
  max-width: 1200px;
  margin: 0 auto;
}
.card-header {
  background: #f8f9fa;
}
.breadcrumb {
  background: none;
  padding-left: 0;
}
</style>
