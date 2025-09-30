<template>
  <div class="liga-anuncio-page">
    <h2>Liga de Anuncios a Licencias</h2>
    <div class="form-section">
      <label>
        <input type="checkbox" v-model="isEmpresa" /> Buscar por Empresa
      </label>
      <div v-if="isEmpresa">
        <label>Empresa:</label>
        <input v-model="empresa" @keyup.enter="buscarEmpresa" />
        <button @click="buscarEmpresa">Buscar</button>
      </div>
      <div v-else>
        <label>Licencia:</label>
        <input v-model="licencia" @keyup.enter="buscarLicencia" />
        <button @click="buscarLicencia">Buscar</button>
      </div>
      <div v-if="licenciaData">
        <div><strong>Propietario:</strong> {{ licenciaData.propietarionvo }}</div>
        <div><strong>Ubicación:</strong> {{ licenciaData.ubicacion }}</div>
        <div><strong>No. Ext.:</strong> {{ licenciaData.numext_ubic }}</div>
        <div><strong>Letra Ext.:</strong> {{ licenciaData.letraext_ubic }}</div>
        <div><strong>No. Int.:</strong> {{ licenciaData.numint_ubic }}</div>
        <div><strong>Letra Int.:</strong> {{ licenciaData.letraint_ubic }}</div>
        <div><strong>Vigente:</strong> {{ licenciaData.vigente }}</div>
      </div>
    </div>
    <hr />
    <div class="form-section">
      <label>Anuncio:</label>
      <input v-model="anuncio" @keyup.enter="buscarAnuncio" />
      <button @click="buscarAnuncio">Buscar</button>
      <div v-if="anuncioData">
        <div><strong>Medidas:</strong> {{ anuncioData.medidas1 }} x {{ anuncioData.medidas2 }}</div>
        <div><strong>Área:</strong> {{ anuncioData.area_anuncio }}</div>
        <div><strong>Ubicación:</strong> {{ anuncioData.ubicacion }}</div>
        <div><strong>No. Ext.:</strong> {{ anuncioData.numext_ubic }}</div>
        <div><strong>Letra Ext.:</strong> {{ anuncioData.letraext_ubic }}</div>
        <div><strong>No. Int.:</strong> {{ anuncioData.numint_ubic }}</div>
        <div><strong>Letra Int.:</strong> {{ anuncioData.letraint_ubic }}</div>
        <div><strong>Colonia:</strong> {{ anuncioData.colonia_ubic }}</div>
        <div><strong>Tipo:</strong> {{ anuncioData.descripcion }}</div>
        <div><strong>Vigente:</strong> {{ anuncioData.vigente }}</div>
      </div>
    </div>
    <hr />
    <div class="form-section">
      <button :disabled="!canLigar" @click="ligarAnuncio">Ligar Anuncio</button>
      <div v-if="message" :class="{'error': !success, 'success': success}">{{ message }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LigaAnuncioPage',
  data() {
    return {
      isEmpresa: false,
      licencia: '',
      empresa: '',
      anuncio: '',
      licenciaData: null,
      empresaData: null,
      anuncioData: null,
      message: '',
      success: false,
      requireConfirmation: false,
      confirmParams: null
    };
  },
  computed: {
    canLigar() {
      return this.anuncioData && (this.licenciaData || this.empresaData);
    }
  },
  methods: {
    async buscarLicencia() {
      this.message = '';
      this.licenciaData = null;
      if (!this.licencia) return;
      const res = await this.api('buscarLicencia', { licencia: this.licencia });
      if (res.success) {
        this.licenciaData = res.data;
      } else {
        this.message = res.message;
        this.success = false;
      }
    },
    async buscarEmpresa() {
      this.message = '';
      this.empresaData = null;
      if (!this.empresa) return;
      const res = await this.api('buscarEmpresa', { empresa: this.empresa });
      if (res.success) {
        this.empresaData = res.data;
      } else {
        this.message = res.message;
        this.success = false;
      }
    },
    async buscarAnuncio() {
      this.message = '';
      this.anuncioData = null;
      if (!this.anuncio) return;
      const res = await this.api('buscarAnuncio', { anuncio: this.anuncio });
      if (res.success) {
        this.anuncioData = res.data;
      } else {
        this.message = res.message;
        this.success = false;
      }
    },
    async ligarAnuncio() {
      this.message = '';
      let params = {
        anuncio_id: this.anuncioData.id_anuncio,
        licencia_id: this.licenciaData ? this.licenciaData.id_licencia : null,
        empresa_id: this.empresaData ? this.empresaData.id_licencia : null,
        isEmpresa: this.isEmpresa,
        user: 'usuario_actual'
      };
      if (this.requireConfirmation && this.confirmParams) {
        params = { ...this.confirmParams, confirmar: true };
      }
      const res = await this.api('ligarAnuncio', params);
      if (res.require_confirmation) {
        if (confirm(res.message)) {
          this.requireConfirmation = true;
          this.confirmParams = params;
          await this.ligarAnuncio();
        } else {
          this.message = 'Operación cancelada por el usuario.';
          this.success = false;
        }
        return;
      }
      this.message = res.message;
      this.success = res.success;
      if (res.success) {
        this.anuncioData = null;
        this.licenciaData = null;
        this.empresaData = null;
        this.licencia = '';
        this.empresa = '';
        this.anuncio = '';
      }
      this.requireConfirmation = false;
      this.confirmParams = null;
    },
    async api(action, params) {
      try {
        const resp = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action, params })
        });
        return await resp.json();
      } catch (e) {
        return { success: false, message: 'Error de red' };
      }
    }
  }
};
</script>

<style scoped>
.liga-anuncio-page {
  max-width: 700px;
  margin: 0 auto;
  background: #fff;
  padding: 2em;
  border-radius: 8px;
  box-shadow: 0 2px 8px #ccc;
}
.form-section {
  margin-bottom: 1.5em;
}
.error {
  color: #b00;
}
.success {
  color: #080;
}
</style>
