<template>
  <div class="imprime-oficio-page">
    <h1>Impresión de Oficio y Pagaré</h1>
    <form @submit.prevent="buscarConvenio">
      <div class="form-row">
        <label>Letras:</label>
        <input v-model="form.letras" maxlength="3" required />
        <label>Número:</label>
        <input v-model.number="form.numero" type="number" min="1" required />
        <label>Año:</label>
        <input v-model.number="form.axo" type="number" min="2005" required />
        <label>Tipo:</label>
        <input v-model.number="form.tipo" type="number" min="1" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="convenio">
      <div class="convenio-info">
        <h2>Convenio: {{ convenio.convenio }}</h2>
        <p><strong>Nombre:</strong> {{ convenio.nombre }}</p>
        <p><strong>Domicilio:</strong> {{ convenio.domicilio }}</p>
        <p><strong>Tipo:</strong> {{ convenio.tipo }}</p>
        <p><strong>Subtipo:</strong> {{ convenio.subtipo }}</p>
        <p><strong>Teléfono:</strong> {{ convenio.telefono }}</p>
        <p><strong>Referencia:</strong> {{ convenio.referencia }}</p>
        <p><strong>Periodos:</strong> {{ convenio.periodos }}</p>
        <p><strong>Cantidad total:</strong> {{ convenio.cantidad_total | currency }}</p>
        <p><strong>Inicial:</strong> {{ convenio.inicial | currency }}</p>
        <p><strong>Parcial:</strong> {{ convenio.parcial | currency }}</p>
      </div>
      <div class="firma-info">
        <h3>Firmas</h3>
        <p><strong>Testigo 1:</strong> <input v-model="firma.testigo1" :disabled="!editTestigo1" /> <button @click="editTestigo1 = true">Editar</button></p>
        <p><strong>Testigo 2:</strong> <input v-model="firma.testigo2" :disabled="!editTestigo2" /> <button @click="editTestigo2 = true">Editar</button></p>
        <p><strong>Firma titular:</strong> <input v-model="firma.titular" :disabled="!editFirmaTitular" /> <button @click="editFirmaTitular = true">Editar</button></p>
        <p><strong>Cargo titular:</strong> <input v-model="firma.cargotitular" :disabled="!editCargoTitular" /> <button @click="editCargoTitular = true">Editar</button></p>
      </div>
      <div class="actions">
        <button @click="imprimirOficio">Imprimir Oficio</button>
        <button @click="imprimirPagare">Imprimir Pagaré</button>
        <button @click="reiniciar">Otro Convenio</button>
        <button @click="salir">Salir</button>
      </div>
      <div v-if="pdfUrl">
        <iframe :src="pdfUrl" width="100%" height="600px"></iframe>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ImprimeOficioPage',
  data() {
    return {
      form: {
        letras: '',
        numero: '',
        axo: '',
        tipo: ''
      },
      convenio: null,
      firma: {
        testigo1: '',
        testigo2: '',
        titular: '',
        cargotitular: ''
      },
      editTestigo1: false,
      editTestigo2: false,
      editFirmaTitular: false,
      editCargoTitular: false,
      error: '',
      pdfUrl: ''
    };
  },
  filters: {
    currency(val) {
      if (!val) return '$0.00';
      return '$' + parseFloat(val).toLocaleString('es-MX', {minimumFractionDigits: 2});
    }
  },
  methods: {
    async buscarConvenio() {
      this.error = '';
      this.pdfUrl = '';
      this.convenio = null;
      this.firma = {testigo1: '', testigo2: '', titular: '', cargotitular: ''};
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'buscar',
            params: this.form
          }
        });
        const r = res.data.eResponse;
        if (r.status === 'ok') {
          this.convenio = r.convenio;
          if (r.firma) {
            this.firma = {
              testigo1: r.firma.testigo1,
              testigo2: r.firma.testigo2,
              titular: r.firma.titular,
              cargotitular: r.firma.cargotitular
            };
          }
        } else {
          this.error = r.message;
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor';
      }
    },
    async imprimirOficio() {
      if (!this.convenio) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'imprimir_oficio',
            params: { id_conv_resto: this.convenio.id_conv_resto }
          }
        });
        const r = res.data.eResponse;
        if (r.status === 'ok') {
          this.pdfUrl = r.pdf_url;
        } else {
          this.error = r.message;
        }
      } catch (e) {
        this.error = 'Error al generar el oficio';
      }
    },
    async imprimirPagare() {
      if (!this.convenio) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'imprimir_pagare',
            params: { id_conv_resto: this.convenio.id_conv_resto }
          }
        });
        const r = res.data.eResponse;
        if (r.status === 'ok') {
          this.pdfUrl = r.pdf_url;
        } else {
          this.error = r.message;
        }
      } catch (e) {
        this.error = 'Error al generar el pagaré';
      }
    },
    reiniciar() {
      this.form = {letras: '', numero: '', axo: '', tipo: ''};
      this.convenio = null;
      this.firma = {testigo1: '', testigo2: '', titular: '', cargotitular: ''};
      this.error = '';
      this.pdfUrl = '';
    },
    salir() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.imprime-oficio-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  display: flex;
  gap: 1rem;
  align-items: center;
  margin-bottom: 1rem;
}
.convenio-info, .firma-info {
  margin-bottom: 1rem;
}
.actions button {
  margin-right: 1rem;
}
.alert {
  color: #b71c1c;
  background: #ffebee;
  padding: 1rem;
  border-radius: 4px;
  margin-bottom: 1rem;
}
</style>
