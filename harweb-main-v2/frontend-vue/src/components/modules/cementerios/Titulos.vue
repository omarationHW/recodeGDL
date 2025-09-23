<template>
  <div class="titulos-page">
    <h1>Impresión de Título de Propiedad</h1>
    <form @submit.prevent="onBuscar">
      <div class="form-row">
        <label>Fecha de Pago:</label>
        <input type="date" v-model="form.fecha" required />
        <label>Folio:</label>
        <input type="number" v-model="form.folio" required />
        <label>Operación:</label>
        <input type="number" v-model="form.operacion" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="titulo">
      <h2>Datos del Título</h2>
      <div class="form-row">
        <label>Título:</label>
        <input type="number" v-model="form.titulo" :readonly="true" />
        <label>Partida:</label>
        <input type="text" v-model="form.partida" />
      </div>
      <div class="form-row">
        <label>Libro:</label>
        <input type="number" v-model="form.libro" />
        <label>Año:</label>
        <input type="number" v-model="form.axo" />
        <label>Folio Libro:</label>
        <input type="number" v-model="form.folio_libro" />
      </div>
      <div class="form-row">
        <label>Nombre Beneficiario:</label>
        <input type="text" v-model="form.nombre" />
      </div>
      <div class="form-row">
        <label>Domicilio Beneficiario:</label>
        <input type="text" v-model="form.domicilio" />
      </div>
      <div class="form-row">
        <label>Colonia Beneficiario:</label>
        <input type="text" v-model="form.colonia" />
      </div>
      <div class="form-row">
        <label>Teléfono Beneficiario:</label>
        <input type="text" v-model="form.telefono" />
      </div>
      <div class="form-row">
        <button @click="onActualizar">Actualizar Beneficiario</button>
        <button @click="onImprimir">Imprimir Título</button>
        <button @click="onLimpiar">Limpiar</button>
      </div>
      <div v-if="mensaje" class="mensaje">{{ mensaje }}</div>
    </div>
    <div v-if="imprimirDatos">
      <h2>Vista Previa de Impresión</h2>
      <pre>{{ imprimirDatos }}</pre>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TitulosPage',
  data() {
    return {
      form: {
        fecha: '',
        folio: '',
        operacion: '',
        titulo: '',
        partida: '',
        libro: '',
        axo: '',
        folio_libro: '',
        nombre: '',
        domicilio: '',
        colonia: '',
        telefono: ''
      },
      titulo: null,
      mensaje: '',
      imprimirDatos: null
    };
  },
  methods: {
    async onBuscar() {
      this.mensaje = '';
      this.imprimirDatos = null;
      try {
        const res = await this.apiRequest('search', {
          fecha: this.form.fecha,
          folio: this.form.folio,
          operacion: this.form.operacion
        });
        if (res.data && res.data.length > 0) {
          this.titulo = res.data[0];
          // Mapear datos al formulario
          this.form.titulo = this.titulo.titulo;
          this.form.partida = this.titulo.partida || '';
          this.form.libro = this.titulo.libro || '';
          this.form.axo = this.titulo.axo || '';
          this.form.folio_libro = this.titulo.folio_libro || '';
          this.form.nombre = this.titulo.nombre_beneficiario || '';
          this.form.domicilio = this.titulo.domicilio_beneficiario || '';
          this.form.colonia = this.titulo.colonia_beneficiario || '';
          this.form.telefono = this.titulo.telefono_beneficiario || '';
        } else {
          this.titulo = null;
          this.mensaje = 'No se encontró el título.';
        }
      } catch (e) {
        this.mensaje = e.message || 'Error en la búsqueda.';
      }
    },
    async onActualizar() {
      this.mensaje = '';
      try {
        const res = await this.apiRequest('update', {
          control_rcm: this.titulo.control_rcm,
          titulo: this.form.titulo,
          fecha: this.form.fecha,
          libro: this.form.libro,
          axo: this.form.axo,
          folio: this.form.folio_libro,
          nombre: this.form.nombre,
          domicilio: this.form.domicilio,
          colonia: this.form.colonia,
          telefono: this.form.telefono,
          partida: this.form.partida
        });
        this.mensaje = 'Beneficiario actualizado correctamente.';
      } catch (e) {
        this.mensaje = e.message || 'Error al actualizar.';
      }
    },
    async onImprimir() {
      this.mensaje = '';
      try {
        const res = await this.apiRequest('print', {
          fecha: this.form.fecha,
          folio: this.form.folio,
          operacion: this.form.operacion
        });
        this.imprimirDatos = res.data;
      } catch (e) {
        this.mensaje = e.message || 'Error al imprimir.';
      }
    },
    onLimpiar() {
      this.form = {
        fecha: '', folio: '', operacion: '', titulo: '', partida: '', libro: '', axo: '', folio_libro: '', nombre: '', domicilio: '', colonia: '', telefono: ''
      };
      this.titulo = null;
      this.imprimirDatos = null;
      this.mensaje = '';
    },
    async apiRequest(action, data) {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: `cementerios.${action}`,
          payload: data
        });
        if (res.data.status === 'success') {
          return res.data;
        } else {
          throw new Error(res.data.message || 'Error en la solicitud');
        }
      } catch (error) {
        throw new Error(error.response?.data?.message || error.message || 'Error de conexión');
      }
    }
  }
};
</script>

<style scoped>
.titulos-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2em;
  background: #f9f9f9;
  border-radius: 8px;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1em;
  margin-bottom: 1em;
}
.form-row label {
  min-width: 120px;
  font-weight: bold;
}
.form-row input {
  flex: 1 1 200px;
  padding: 0.3em;
}
button {
  padding: 0.5em 1.2em;
  margin-right: 1em;
}
.mensaje {
  color: #b00;
  margin-top: 1em;
}
</style>
