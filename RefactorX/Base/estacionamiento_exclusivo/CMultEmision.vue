<template>
  <div class="cmult-emision-page">
    <h1>Consulta Múltiple por Fecha de Emisión</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Múltiple por Fecha de Emisión</li>
      </ol>
    </nav>
    <form @submit.prevent="buscarFolios">
      <div class="form-row align-items-end">
        <div class="form-group col-md-2">
          <label for="recaudadora">Recaudadora</label>
          <select v-model="form.zona" class="form-control" id="recaudadora" required>
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
          </select>
        </div>
        <div class="form-group col-md-3">
          <label for="fecha_emision">Fecha de Emisión</label>
          <input type="date" v-model="form.fecha_emision" class="form-control" id="fecha_emision" required />
        </div>
        <div class="form-group col-md-4">
          <label>Aplicación</label>
          <div>
            <div class="form-check form-check-inline" v-for="mod in modulos" :key="mod.value">
              <input class="form-check-input" type="radio" :id="'modulo'+mod.value" v-model="form.modulo" :value="mod.value" required>
              <label class="form-check-label" :for="'modulo'+mod.value">{{ mod.label }}</label>
            </div>
          </div>
        </div>
        <div class="form-group col-md-2">
          <button type="submit" class="btn btn-primary btn-block">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="my-3 text-center">
      <span class="spinner-border"></span> Buscando...
    </div>
    <div v-if="folios.length > 0">
      <h3 class="mt-4">Folios encontrados</h3>
      <table class="table table-sm table-bordered table-hover">
        <thead>
          <tr>
            <th>Zona</th>
            <th>Módulo</th>
            <th>Control Otr</th>
            <th>Folio</th>
            <th>Diligencia</th>
            <th>Importe Global</th>
            <th>Importe Multa</th>
            <th>Importe Recargo</th>
            <th>Importe Actualización</th>
            <th>Importe Gastos</th>
            <th>Zona Apremio</th>
            <th>Fecha Emisión</th>
            <th>Clave Practicado</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="folio in folios" :key="folio.id_control">
            <td>{{ folio.zona }}</td>
            <td>{{ folio.modulo }}</td>
            <td>{{ folio.control_otr }}</td>
            <td>{{ folio.folio }}</td>
            <td>{{ folio.diligencia }}</td>
            <td>{{ folio.importe_global | currency }}</td>
            <td>{{ folio.importe_multa | currency }}</td>
            <td>{{ folio.importe_recargo | currency }}</td>
            <td>{{ folio.importe_actualizacion | currency }}</td>
            <td>{{ folio.importe_gastos | currency }}</td>
            <td>{{ folio.zona_apremio }}</td>
            <td>{{ folio.fecha_emision }}</td>
            <td>{{ folio.clave_practicado }}</td>
            <td>
              <button class="btn btn-sm btn-info" @click="verDetalle(folio.id_control)">Ver Detalle</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="detalleFolio">
      <h4>Detalle del Folio</h4>
      <pre>{{ detalleFolio }}</pre>
      <button class="btn btn-secondary" @click="detalleFolio = null">Cerrar</button>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'CMultEmisionPage',
  data() {
    return {
      recaudadoras: [],
      modulos: [
        { value: 11, label: 'Mercados' },
        { value: 16, label: 'Aseo' },
        { value: 24, label: 'Est. Públicos' },
        { value: 28, label: 'Est. Exclusivos' },
        { value: 14, label: 'Estacionómetros' },
        { value: 13, label: 'Cementerios' }
      ],
      form: {
        zona: '',
        modulo: '',
        fecha_emision: ''
      },
      folios: [],
      detalleFolio: null,
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  },
  created() {
    this.fetchRecaudadoras();
    this.form.fecha_emision = new Date().toISOString().substr(0, 10);
  },
  methods: {
    async fetchRecaudadoras() {
      try {
        const res = await this.$axios.post('/api/execute', { action: 'getRecaudadoras' });
        if (res.data.success) {
          this.recaudadoras = res.data.data;
          if (this.recaudadoras.length > 0) {
            this.form.zona = this.recaudadoras[0].id_rec;
          }
        }
      } catch (e) {
        this.error = 'Error cargando recaudadoras';
      }
    },
    async buscarFolios() {
      this.loading = true;
      this.error = '';
      this.folios = [];
      this.detalleFolio = null;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'searchFoliosByFechaEmision',
          params: {
            modulo: this.form.modulo,
            zona: this.form.zona,
            fecha_emision: this.form.fecha_emision
          }
        });
        if (res.data.success) {
          this.folios = res.data.data;
        } else {
          this.error = res.data.message || 'No se encontraron folios.';
        }
      } catch (e) {
        this.error = 'Error buscando folios.';
      } finally {
        this.loading = false;
      }
    },
    async verDetalle(id_control) {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getFolioDetail',
          params: { id_control }
        });
        if (res.data.success) {
          this.detalleFolio = res.data.data[0] || {};
        } else {
          this.error = res.data.message || 'No se encontró el detalle.';
        }
      } catch (e) {
        this.error = 'Error obteniendo detalle.';
      }
    }
  }
};
</script>

<style scoped>
.cmult-emision-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
