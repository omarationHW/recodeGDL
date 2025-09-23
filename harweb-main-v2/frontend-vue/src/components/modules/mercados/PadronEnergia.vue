<template>
  <div class="padron-energia-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Padrón de Energía Eléctrica</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header">Filtros</div>
      <div class="card-body row g-3 align-items-end">
        <div class="col-md-2">
          <label for="recaudadora" class="form-label">Oficina</label>
          <select v-model="selectedRecaudadora" @change="onRecaudadoraChange" class="form-select" id="recaudadora">
            <option value="" disabled>Seleccione...</option>
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
          </select>
        </div>
        <div class="col-md-4">
          <label for="mercado" class="form-label">Mercado</label>
          <select v-model="selectedMercado" class="form-select" id="mercado">
            <option value="" disabled>Seleccione...</option>
            <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.num_mercado_nvo }} - {{ merc.descripcion }}</option>
          </select>
        </div>
        <div class="col-md-2">
          <button class="btn btn-primary w-100" @click="buscarPadron" :disabled="loading">Buscar</button>
        </div>
        <div class="col-md-2">
          <button class="btn btn-success w-100" @click="exportarExcel" :disabled="!padron.length">Exportar Excel</button>
        </div>
        <div class="col-md-2">
          <button class="btn btn-secondary w-100" @click="imprimirPDF" :disabled="!padron.length">Imprimir PDF</button>
        </div>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="padron.length" class="table-responsive">
      <table class="table table-striped table-bordered">
        <thead>
          <tr>
            <th>Rec.</th>
            <th>Merc.</th>
            <th>Cat.</th>
            <th>Sec.</th>
            <th>Local</th>
            <th>Letra</th>
            <th>Bloque</th>
            <th>Adicionales</th>
            <th>Nombre</th>
            <th>Consumo</th>
            <th>Kilowhatts/Cuota</th>
            <th>Vigencia</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in padron" :key="row.id_local">
            <td>{{ row.oficina }}</td>
            <td>{{ row.num_mercado }}</td>
            <td>{{ row.categoria }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.local }}</td>
            <td>{{ row.letra_local }}</td>
            <td>{{ row.bloque }}</td>
            <td>{{ row.local_adicional }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.cve_consumo }}</td>
            <td>{{ row.cantidad }}</td>
            <td>{{ row.vigencia }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!loading && !error" class="alert alert-warning">No hay datos para mostrar.</div>
  </div>
</template>

<script>
export default {
  name: 'PadronEnergiaPage',
  data() {
    return {
      recaudadoras: [],
      mercados: [],
      selectedRecaudadora: '',
      selectedMercado: '',
      padron: [],
      loading: false,
      error: ''
    };
  },
  mounted() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getRecaudadoras'
        });
        if (res.data.success) {
          this.recaudadoras = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar recaudadoras';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async onRecaudadoraChange() {
      this.selectedMercado = '';
      this.mercados = [];
      if (!this.selectedRecaudadora) return;
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getMercadosByRecaudadora',
          params: { id_rec: this.selectedRecaudadora }
        });
        if (res.data.success) {
          this.mercados = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar mercados';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async buscarPadron() {
      if (!this.selectedRecaudadora || !this.selectedMercado) {
        this.error = 'Seleccione oficina y mercado';
        return;
      }
      this.loading = true;
      this.error = '';
      this.padron = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getPadronEnergia',
          params: {
            id_rec: this.selectedRecaudadora,
            num_mercado_nvo: this.selectedMercado
          }
        });
        if (res.data.success) {
          this.padron = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar padrón';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async exportarExcel() {
      if (!this.selectedRecaudadora || !this.selectedMercado) return;
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'exportPadronEnergiaExcel',
          params: {
            id_rec: this.selectedRecaudadora,
            num_mercado_nvo: this.selectedMercado
          }
        });
        if (res.data.success && res.data.data.url) {
          window.open(res.data.data.url, '_blank');
        } else {
          this.error = res.data.message || 'No se pudo exportar.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async imprimirPDF() {
      if (!this.selectedRecaudadora || !this.selectedMercado) return;
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'printPadronEnergia',
          params: {
            id_rec: this.selectedRecaudadora,
            num_mercado_nvo: this.selectedMercado
          }
        });
        if (res.data.success && res.data.data.url) {
          window.open(res.data.data.url, '_blank');
        } else {
          this.error = res.data.message || 'No se pudo imprimir.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.padron-energia-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.card {
  margin-bottom: 1rem;
}
.table {
  font-size: 0.95rem;
}
</style>
