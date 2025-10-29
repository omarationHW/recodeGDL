<template>
  <div class="cmultfolio-page">
    <h1>Consulta Múltiple por Folio de Requerimiento</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Múltiple Folio</li>
      </ol>
    </nav>
    <form @submit.prevent="buscarFolios">
      <div class="row mb-3">
        <div class="col-md-2">
          <label for="aplicacion">Aplicación</label>
          <select v-model="form.modulo" class="form-control" id="aplicacion">
            <option v-for="ap in aplicaciones" :key="ap.value" :value="ap.value">{{ ap.label }}</option>
          </select>
        </div>
        <div class="col-md-2">
          <label for="recaudadora">Recaudadora</label>
          <select v-model="form.zona" class="form-control" id="recaudadora">
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }}</option>
          </select>
        </div>
        <div class="col-md-2">
          <label for="folio">Folio</label>
          <input v-model.number="form.folio" type="number" min="1" class="form-control" id="folio" required />
        </div>
        <div class="col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Buscando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="folios.length">
      <table class="table table-striped table-bordered">
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
            <td>{{ folio.importe_global }}</td>
            <td>{{ folio.importe_multa }}</td>
            <td>{{ folio.importe_recargo }}</td>
            <td>{{ folio.importe_actualizacion }}</td>
            <td>{{ folio.importe_gastos }}</td>
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
    <div v-if="detalle">
      <h3>Detalle del Folio</h3>
      <pre>{{ detalle }}</pre>
      <button class="btn btn-secondary" @click="detalle = null">Cerrar</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CMultFolioPage',
  data() {
    return {
      aplicaciones: [
        { value: 11, label: 'Mercados' },
        { value: 16, label: 'Aseo' },
        { value: 24, label: 'Est. Públicos' },
        { value: 28, label: 'Est. Exclusivos' },
        { value: 14, label: 'Estacionómetros' },
        { value: 13, label: 'Cementerios' }
      ],
      recaudadoras: [],
      form: {
        modulo: 11,
        zona: null,
        folio: 1
      },
      folios: [],
      detalle: null,
      loading: false,
      error: ''
    };
  },
  created() {
    this.cargarRecaudadoras();
  },
  methods: {
    async cargarRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action: 'list_recaudadoras' } })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.recaudadoras = data.eResponse.recaudadoras;
          if (this.recaudadoras.length) {
            this.form.zona = this.recaudadoras[0].id_rec;
          }
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error al cargar recaudadoras';
      } finally {
        this.loading = false;
      }
    },
    async buscarFolios() {
      this.loading = true;
      this.error = '';
      this.folios = [];
      this.detalle = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'search_folios',
              params: {
                modulo: this.form.modulo,
                zona: this.form.zona,
                folio: this.form.folio
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.folios = data.eResponse.folios;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error al buscar folios';
      } finally {
        this.loading = false;
      }
    },
    async verDetalle(id_control) {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'folio_detail',
              params: { id_control }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.detalle = data.eResponse.detail;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error al obtener detalle';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.cmultfolio-page {
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
