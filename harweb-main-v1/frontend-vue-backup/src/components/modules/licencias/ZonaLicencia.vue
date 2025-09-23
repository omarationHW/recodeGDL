<template>
  <div class="zona-licencia-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Zona y Subzona de Licencia</li>
      </ol>
    </nav>
    <h2>Actualización de Zona y Subzona de Licencia</h2>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <form @submit.prevent="onSubmit" v-if="!loading">
      <div class="form-group">
        <label for="licencia">Licencia</label>
        <input type="text" class="form-control" id="licencia" v-model="form.licencia" @blur="fetchLicencia" required />
      </div>
      <div v-if="licenciaData">
        <div class="form-group">
          <label>Actividad</label>
          <input type="text" class="form-control" :value="licenciaData.actividad" readonly />
        </div>
        <div class="form-group">
          <label>Ubicación</label>
          <input type="text" class="form-control" :value="licenciaData.ubicacion" readonly />
        </div>
        <div class="form-row">
          <div class="form-group col-md-4">
            <label for="recaud">Recaudadora</label>
            <select class="form-control" id="recaud" v-model="form.recaud" @change="fetchZonas" required>
              <option v-for="rec in recaudadoras" :key="rec.recaud" :value="rec.recaud">
                {{ rec.recaud }} - {{ rec.descripcion }}
              </option>
            </select>
          </div>
          <div class="form-group col-md-4">
            <label for="zona">Zona</label>
            <select class="form-control" id="zona" v-model="form.zona" @change="fetchSubzonas" required>
              <option v-for="zona in zonas" :key="zona.cvezona" :value="zona.cvezona">
                {{ zona.cvezona }} - {{ zona.zona }}
              </option>
            </select>
          </div>
          <div class="form-group col-md-4">
            <label for="subzona">Subzona</label>
            <select class="form-control" id="subzona" v-model="form.subzona" required>
              <option v-for="subzona in subzonas" :key="subzona.cvesubzona" :value="subzona.cvesubzona">
                {{ subzona.cvesubzona }} - {{ subzona.descsubzon }}
              </option>
            </select>
          </div>
        </div>
        <button type="submit" class="btn btn-primary">Guardar</button>
        <span v-if="success" class="text-success ml-3">¡Guardado correctamente!</span>
        <span v-if="error" class="text-danger ml-3">{{ error }}</span>
      </div>
    </form>
  </div>
</template>

<script>
export default {
  name: 'ZonaLicenciaPage',
  data() {
    return {
      loading: false,
      licenciaData: null,
      zonas: [],
      subzonas: [],
      recaudadoras: [],
      form: {
        licencia: '',
        zona: '',
        subzona: '',
        recaud: ''
      },
      success: false,
      error: ''
    }
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    async api(action, params = {}) {
      return await this.$axios.post('/api/execute', { action, params });
    },
    async fetchRecaudadoras() {
      this.loading = true;
      try {
        const res = await this.api('get_recaudadoras');
        this.recaudadoras = res.data.data;
      } catch (e) {
        this.error = 'Error cargando recaudadoras';
      } finally {
        this.loading = false;
      }
    },
    async fetchZonas() {
      if (!this.form.recaud) return;
      this.loading = true;
      try {
        const res = await this.api('get_zonas', { recaud: this.form.recaud });
        this.zonas = res.data.data;
        this.form.zona = '';
        this.subzonas = [];
        this.form.subzona = '';
      } catch (e) {
        this.error = 'Error cargando zonas';
      } finally {
        this.loading = false;
      }
    },
    async fetchSubzonas() {
      if (!this.form.zona || !this.form.recaud) return;
      this.loading = true;
      try {
        const res = await this.api('get_subzonas', { cvezona: this.form.zona, recaud: this.form.recaud });
        this.subzonas = res.data.data;
        this.form.subzona = '';
      } catch (e) {
        this.error = 'Error cargando subzonas';
      } finally {
        this.loading = false;
      }
    },
    async fetchLicencia() {
      if (!this.form.licencia) return;
      this.loading = true;
      this.success = false;
      this.error = '';
      try {
        const res = await this.api('get_licencia', { licencia: this.form.licencia });
        if (!res.data.data) {
          this.licenciaData = null;
          this.error = 'Licencia no encontrada';
          return;
        }
        this.licenciaData = res.data.data;
        // Cargar valores actuales de zona/subzona/recaud
        const zonaRes = await this.api('get_licencias_zona', { licencia: this.form.licencia });
        if (zonaRes.data.data) {
          this.form.zona = zonaRes.data.data.zona;
          this.form.subzona = zonaRes.data.data.subzona;
          this.form.recaud = zonaRes.data.data.recaud;
        } else {
          this.form.zona = '';
          this.form.subzona = '';
          this.form.recaud = '';
        }
        await this.fetchZonas();
        if (this.form.zona) await this.fetchSubzonas();
      } catch (e) {
        this.error = 'Error cargando licencia';
      } finally {
        this.loading = false;
      }
    },
    async onSubmit() {
      this.success = false;
      this.error = '';
      if (!this.form.licencia || !this.form.zona || !this.form.subzona || !this.form.recaud) {
        this.error = 'Todos los campos son obligatorios';
        return;
      }
      this.loading = true;
      try {
        await this.api('save_licencias_zona', {
          licencia: this.form.licencia,
          zona: this.form.zona,
          subzona: this.form.subzona,
          recaud: this.form.recaud
        });
        this.success = true;
      } catch (e) {
        this.error = 'Error guardando zona';
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.zona-licencia-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
