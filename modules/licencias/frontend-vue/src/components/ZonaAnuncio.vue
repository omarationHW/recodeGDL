<template>
  <div class="zona-anuncio-page">
    <h1>Actualización de Zona y Subzona de Anuncio</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-group">
        <label for="anuncio">Anuncio</label>
        <input v-model="form.anuncio" type="number" id="anuncio" required :readonly="!!form.anuncio" />
      </div>
      <div class="form-group">
        <label for="zona">Zona</label>
        <select v-model="form.zona" id="zona" required>
          <option v-for="z in catalogs.zonas" :key="z.id" :value="z.id">{{ z.descripcion }}</option>
        </select>
      </div>
      <div class="form-group">
        <label for="subzona">Subzona</label>
        <select v-model="form.subzona" id="subzona" required>
          <option v-for="sz in filteredSubzonas" :key="sz.id" :value="sz.id">{{ sz.descripcion }}</option>
        </select>
      </div>
      <div class="form-group">
        <label for="recaud">Recaudadora</label>
        <select v-model="form.recaud" id="recaud" required>
          <option v-for="r in catalogs.recaudadoras" :key="r.id" :value="r.id">{{ r.descripcion }}</option>
        </select>
      </div>
      <div class="form-actions">
        <button type="submit" class="btn btn-primary">Guardar</button>
        <button type="button" class="btn btn-secondary" @click="onCancel">Cancelar</button>
      </div>
    </form>
    <div v-if="message" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">{{ message }}</div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'ZonaAnuncioPage',
  data() {
    return {
      form: {
        anuncio: '',
        zona: '',
        subzona: '',
        recaud: ''
      },
      catalogs: {
        zonas: [],
        subzonas: [],
        recaudadoras: []
      },
      message: '',
      success: true,
      loading: false
    };
  },
  computed: {
    filteredSubzonas() {
      if (!this.form.zona) return [];
      return this.catalogs.subzonas.filter(sz => sz.cvezona == this.form.zona);
    }
  },
  created() {
    this.loadCatalogs();
    // Si viene por edición, cargar datos
    if (this.$route.params.anuncio) {
      this.loadAnuncioZona(this.$route.params.anuncio);
    }
  },
  methods: {
    async loadCatalogs() {
      try {
        const res = await axios.post('/api/execute', { action: 'zonaanuncio.catalogs' });
        this.catalogs = res.data;
      } catch (e) {
        this.message = 'Error cargando catálogos';
        this.success = false;
      }
    },
    async loadAnuncioZona(anuncio) {
      try {
        const res = await axios.post('/api/execute', { action: 'zonaanuncio.get', params: { anuncio } });
        if (res.data.data) {
          this.form = {
            anuncio: res.data.data.anuncio,
            zona: res.data.data.zona,
            subzona: res.data.data.subzona,
            recaud: res.data.data.recaud
          };
        }
      } catch (e) {
        this.message = 'No se encontró el registro';
        this.success = false;
      }
    },
    async onSubmit() {
      this.loading = true;
      this.message = '';
      try {
        let action = this.form.anuncio && this.form.zona ? 'zonaanuncio.update' : 'zonaanuncio.create';
        const res = await axios.post('/api/execute', {
          action,
          params: { ...this.form }
        });
        if (res.data.success) {
          this.message = 'Guardado correctamente';
          this.success = true;
        } else {
          this.message = res.data.error || 'Error al guardar';
          this.success = false;
        }
      } catch (e) {
        this.message = e.response?.data?.error || 'Error de red';
        this.success = false;
      } finally {
        this.loading = false;
      }
    },
    onCancel() {
      this.$router.push({ name: 'anuncios-list' });
    }
  }
};
</script>

<style scoped>
.zona-anuncio-page {
  max-width: 600px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.form-group {
  margin-bottom: 1rem;
}
.form-actions {
  margin-top: 2rem;
  display: flex;
  gap: 1rem;
}
.alert {
  margin-top: 1rem;
  padding: 0.75rem 1rem;
  border-radius: 4px;
}
.alert-success {
  background: #e6ffed;
  color: #1a7f37;
}
.alert-danger {
  background: #ffeaea;
  color: #a94442;
}
</style>
