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
        const eRequest = {
          Operacion: 'sp_zonaanuncio_catalogs',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: []
        }
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })
        const res = await response.json()
        this.catalogs = res.eResponse.data || {};
      } catch (e) {
        this.message = 'Error cargando catálogos';
        this.success = false;
      }
    },
    async loadAnuncioZona(anuncio) {
      try {
        const eRequest = {
          Operacion: 'sp_zonaanuncio_get',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_anuncio', valor: anuncio }
          ]
        }
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })
        const res = await response.json()
        if (res.eResponse.data.result) {
          this.form = {
            anuncio: res.eResponse.data.result.anuncio,
            zona: res.eResponse.data.result.zona,
            subzona: res.eResponse.data.result.subzona,
            recaud: res.eResponse.data.result.recaud
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
        let operacion = this.form.anuncio && this.form.zona ? 'sp_zonaanuncio_update' : 'sp_zonaanuncio_create';
        const eRequest = {
          Operacion: operacion,
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_anuncio', valor: this.form.anuncio },
            { nombre: 'p_zona', valor: this.form.zona },
            { nombre: 'p_subzona', valor: this.form.subzona },
            { nombre: 'p_recaud', valor: this.form.recaud }
          ]
        }
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })
        const res = await response.json()
        if (res.eResponse.success) {
          this.message = 'Guardado correctamente';
          this.success = true;
        } else {
          this.message = res.eResponse.message || 'Error al guardar';
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error de red';
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
