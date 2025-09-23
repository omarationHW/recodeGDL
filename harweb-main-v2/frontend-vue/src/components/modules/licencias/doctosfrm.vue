<template>
  <div class="doctosfrm-page">
    <h1>Documentación necesaria</h1>
    <form @submit.prevent="onSubmit">
      <div v-for="(doc, idx) in catalogo" :key="doc.codigo" class="form-check">
        <input type="checkbox" :id="'doc_'+doc.codigo" v-model="seleccionados" :value="doc.codigo" />
        <label :for="'doc_'+doc.codigo">{{ doc.descripcion }}</label>
      </div>
      <div class="form-check">
        <input type="checkbox" id="doc_otro" v-model="otroChecked" />
        <label for="doc_otro">Otro</label>
        <input v-if="otroChecked" type="text" v-model="otroTexto" placeholder="Especifique otro documento" class="form-control" />
      </div>
      <div class="mt-4">
        <button type="submit" class="btn btn-primary">Aceptar</button>
        <button type="button" class="btn btn-secondary" @click="onCancel">Cancelar</button>
        <button type="button" class="btn btn-warning" @click="onClear">Limpiar</button>
      </div>
    </form>
    <div v-if="mensaje" class="alert alert-info mt-3">{{ mensaje }}</div>
  </div>
</template>

<script>
export default {
  name: 'DoctosFrmPage',
  data() {
    return {
      catalogo: [],
      seleccionados: [],
      otroChecked: false,
      otroTexto: '',
      mensaje: '',
      tramite_id: null // Debe ser asignado desde la navegación o props
    };
  },
  created() {
    // Cargar catálogo de documentos
    this.loadCatalogo();
    // Si viene tramite_id por props o ruta, cargar selección previa
    if (this.$route && this.$route.params.tramite_id) {
      this.tramite_id = this.$route.params.tramite_id;
      this.loadSeleccionados();
    }
  },
  methods: {
    async loadCatalogo() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'list', data: {} } })
      });
      const json = await res.json();
      if (json.eResponse && json.eResponse.success) {
        this.catalogo = json.eResponse.data;
      }
    },
    async loadSeleccionados() {
      if (!this.tramite_id) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'get', data: { tramite_id: this.tramite_id } } })
      });
      const json = await res.json();
      if (json.eResponse && json.eResponse.success && json.eResponse.data) {
        this.seleccionados = json.eResponse.data.documentos || [];
        if (json.eResponse.data.otro) {
          this.otroChecked = true;
          this.otroTexto = json.eResponse.data.otro;
        }
      }
    },
    async onSubmit() {
      if (!this.tramite_id) {
        this.mensaje = 'No se ha indicado el trámite.';
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'save',
            data: {
              tramite_id: this.tramite_id,
              documentos: this.seleccionados,
              otro: this.otroChecked ? this.otroTexto : null
            }
          }
        })
      });
      const json = await res.json();
      if (json.eResponse && json.eResponse.success) {
        this.mensaje = 'Documentos guardados correctamente.';
      } else {
        this.mensaje = json.eResponse.message || 'Error al guardar.';
      }
    },
    async onClear() {
      this.seleccionados = [];
      this.otroChecked = false;
      this.otroTexto = '';
      if (this.tramite_id) {
        await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action: 'clear', data: { tramite_id: this.tramite_id } } })
        });
        this.mensaje = 'Selección limpiada.';
      }
    },
    onCancel() {
      this.$router.back();
    }
  }
};
</script>

<style scoped>
.doctosfrm-page {
  max-width: 500px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.form-check {
  margin-bottom: 0.5rem;
}
</style>
