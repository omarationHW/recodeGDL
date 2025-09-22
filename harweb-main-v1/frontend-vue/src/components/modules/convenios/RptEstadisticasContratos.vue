<template>
  <div class="estadisticas-contratos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estadísticas de Contratos</li>
      </ol>
    </nav>
    <h1>Estadísticas de Pagos de Contratos</h1>
    <form @submit.prevent="fetchEstadisticas">
      <div class="row mb-3">
        <div class="col-md-4">
          <label for="year">Año de Obra</label>
          <select v-model="form.year" id="year" class="form-control" required>
            <option v-for="anio in anios" :key="anio" :value="anio">{{ anio }}</option>
          </select>
        </div>
        <div class="col-md-4">
          <label for="fondo">Fondo/Programa</label>
          <select v-model="form.fondo" id="fondo" class="form-control" required>
            <option v-for="fondo in fondos" :key="fondo.id" :value="fondo.id">{{ fondo.descripcion }}</option>
          </select>
        </div>
        <div class="col-md-4 d-flex align-items-end">
          <button type="submit" class="btn btn-primary mr-2">Consultar</button>
          <button type="button" class="btn btn-success" @click="exportar" :disabled="loading || !estadisticas.length">Exportar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="estadisticas.length">
      <table class="table table-bordered table-sm mt-3">
        <thead class="thead-light">
          <tr>
            <th>Colonia</th>
            <th>Descripción</th>
            <th>Convenios</th>
            <th>Costo Total</th>
            <th>Pagos Ingreso</th>
            <th>Devolución</th>
            <th>Diferencia</th>
            <th>Total Calculado</th>
            <th>Saldo</th>
            <th>% Pagado</th>
            <th>% Saldo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in estadisticas" :key="row.numcolonia">
            <td>{{ row.numcolonia }}</td>
            <td>{{ row.nombrecolonia }}</td>
            <td>{{ row.convenios }}</td>
            <td>{{ currency(row.costo) }}</td>
            <td>{{ currency(row.pagos_ing) }}</td>
            <td>{{ currency(row.pagos_dev) }}</td>
            <td>{{ currency(row.pagos_dif) }}</td>
            <td>{{ currency(row.pagos_real) }}</td>
            <td>{{ currency(row.saldo_real) }}</td>
            <td>{{ percent(row.pagos_ing, row.costo) }}</td>
            <td>{{ percent(row.saldo_real, row.costo) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EstadisticasContratosPage',
  data() {
    return {
      form: {
        year: '',
        fondo: ''
      },
      anios: [],
      fondos: [],
      estadisticas: [],
      loading: false,
      error: ''
    }
  },
  created() {
    this.fetchAnios();
    this.fetchFondos();
  },
  methods: {
    async fetchAnios() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'getAniosObra' }
        });
        this.anios = res.data.eResponse.data;
        if (this.anios.length) this.form.year = this.anios[0];
      } catch (e) {
        this.error = 'Error cargando años de obra';
      } finally {
        this.loading = false;
      }
    },
    async fetchFondos() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'getFondos' }
        });
        this.fondos = res.data.eResponse.data;
        if (this.fondos.length) this.form.fondo = this.fondos[0].id;
      } catch (e) {
        this.error = 'Error cargando fondos';
      } finally {
        this.loading = false;
      }
    },
    async fetchEstadisticas() {
      this.loading = true;
      this.error = '';
      this.estadisticas = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'getEstadisticasContratos',
            params: {
              year: this.form.year,
              fondo: this.form.fondo
            }
          }
        });
        if (res.data.eResponse.success) {
          this.estadisticas = (res.data.eResponse.data || []).map(row => ({
            numcolonia: row.numcolonia || row.numcolonia || row.NumColonia,
            nombrecolonia: row.nombrecolonia || row.NombreColonia,
            convenios: row.convenios || row.convenios || row.Count,
            costo: row.costo || row.Costo,
            pagos_ing: row.pagos_ing || row.Pagos_Ing,
            pagos_dev: row.pagos_dev || row.Pagos_dev,
            pagos_dif: row.pagos_dif || row.Pagos_dif,
            pagos_real: row.pagos_real || row.Pagos_real,
            saldo_real: row.saldo_real || row.Saldo_real
          }));
        } else {
          this.error = res.data.eResponse.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = 'Error consultando estadísticas';
      } finally {
        this.loading = false;
      }
    },
    async exportar() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'exportEstadisticasContratos',
            params: {
              year: this.form.year,
              fondo: this.form.fondo
            }
          }
        });
        // Aquí se puede manejar la descarga del archivo si el backend lo implementa
        alert('Exportación generada correctamente.');
      } catch (e) {
        this.error = 'Error exportando';
      } finally {
        this.loading = false;
      }
    },
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    },
    percent(a, b) {
      if (!b || b == 0) return '0.00%';
      return ((a * 100) / b).toFixed(2) + '%';
    }
  }
}
</script>

<style scoped>
.estadisticas-contratos-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
</style>
